package com.twojafirma.imperiumkopalni

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import org.json.JSONObject

/**
 * Google Play Billing. Identyfikatory produktów muszą być takie same jak w Google Play Console
 * (Zarabianie → Produkty → Produkty w aplikacji).
 */
class BillingManager(
    private val activity: MainActivity,
    private val callJs: (String, List<Any?>, ((String?) -> Unit)?) -> Unit,
) : PurchasesUpdatedListener {

    companion object {
        private const val TAG = "ImperiumBilling"
        val CONSUMABLE = setOf("diamonds80", "diamonds500", "diamonds1200")
        val PERMANENT = setOf("doubleincome", "offlinevault")
        val ALL = CONSUMABLE + PERMANENT
    }

    private val client: BillingClient = BillingClient.newBuilder(activity)
        .setListener(this)
        .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
        .build()

    private val products = mutableMapOf<String, ProductDetails>()
    private val owned = mutableSetOf<String>()
    private val handler = Handler(Looper.getMainLooper())
    private var retryDelayMs = 2_000L

    fun start() = connect()

    fun end() = client.endConnection()

    private fun connect() {
        if (client.isReady) return
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    retryDelayMs = 2_000L
                    queryProducts()
                    refreshPurchases()
                } else {
                    Log.w(TAG, "Billing setup failed: ${result.debugMessage}")
                    scheduleReconnect()
                }
            }

            override fun onBillingServiceDisconnected() = scheduleReconnect()
        })
    }

    private fun scheduleReconnect() {
        handler.postDelayed({ connect() }, retryDelayMs)
        retryDelayMs = (retryDelayMs * 2).coerceAtMost(60_000L)
    }

    private fun queryProducts() {
        val list = ALL.map {
            QueryProductDetailsParams.Product.newBuilder()
                .setProductId(it)
                .setProductType(BillingClient.ProductType.INAPP)
                .build()
        }
        val params = QueryProductDetailsParams.newBuilder().setProductList(list).build()
        client.queryProductDetailsAsync(params) { result, details ->
            if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                Log.w(TAG, "Product query failed: ${result.debugMessage}")
                return@queryProductDetailsAsync
            }
            for (pd in details.productDetailsList) products[pd.productId] = pd
            activity.runOnUiThread { pushStateToGame() }
        }
    }

    /** Wysyła do gry ceny w lokalnej walucie i stan ulepszeń na zawsze. */
    fun pushStateToGame() {
        val prices = JSONObject()
        for ((id, pd) in products) {
            pd.oneTimePurchaseOfferDetails?.formattedPrice?.let { prices.put(id, it) }
        }
        if (prices.length() > 0) callJs("onPrices", listOf(prices), null)
        if (client.isReady) {
            val ent = JSONObject()
            for (id in PERMANENT) ent.put(id, owned.contains(id))
            callJs("onEntitlements", listOf(ent), null)
        }
    }

    fun buy(productId: String) {
        val pd = products[productId]
        if (!client.isReady || pd == null) {
            callJs("onBillingMessage", listOf("Sklep Google Play jest teraz niedostępny. Spróbuj za chwilę."), null)
            connect()
            return
        }
        val params = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(
                listOf(BillingFlowParams.ProductDetailsParams.newBuilder().setProductDetails(pd).build())
            )
            .build()
        client.launchBillingFlow(activity, params)
    }

    fun restore() {
        refreshPurchases {
            val msg = if (owned.isEmpty()) "Nie znaleziono zakupów do przywrócenia." else "Zakupy zostały przywrócone."
            callJs("onBillingMessage", listOf(msg), null)
        }
    }

    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> purchases?.forEach { handlePurchase(it) }
            BillingClient.BillingResponseCode.USER_CANCELED -> Unit
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> refreshPurchases()
            else -> callJs("onBillingMessage", listOf("Zakup nie powiódł się (${result.responseCode})."), null)
        }
    }

    /** Sprawdza zakupy: przywraca ulepszenia i dolicza diamenty, których gra jeszcze nie dostała. */
    fun refreshPurchases(done: (() -> Unit)? = null) {
        if (!client.isReady) { done?.invoke(); return }
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()
        client.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                owned.clear()
                for (p in purchases) {
                    if (p.purchaseState != Purchase.PurchaseState.PURCHASED) continue
                    owned.addAll(p.products.filter { it in PERMANENT })
                    handlePurchase(p)
                }
                activity.runOnUiThread { pushStateToGame() }
            }
            activity.runOnUiThread { done?.invoke() }
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        when (purchase.purchaseState) {
            Purchase.PurchaseState.PENDING -> {
                callJs("onBillingMessage", listOf("Płatność oczekuje na potwierdzenie."), null)
                return
            }
            Purchase.PurchaseState.PURCHASED -> Unit
            else -> return
        }
        for (id in purchase.products) {
            if (id in PERMANENT) owned.add(id)
            // Gra nalicza nagrodę (raz na token) i zwraca true – dopiero wtedy kończymy transakcję w Google Play.
            callJs("onPurchase", listOf(id, purchase.purchaseToken)) { granted ->
                if (granted != "true") {
                    Log.w(TAG, "Game did not confirm $id")
                } else if (id in CONSUMABLE) {
                    val consume = ConsumeParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
                    client.consumeAsync(consume) { r, _ -> Log.d(TAG, "consume $id: ${r.responseCode}") }
                } else if (!purchase.isAcknowledged) {
                    val ack = AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
                    client.acknowledgePurchase(ack) { r -> Log.d(TAG, "ack $id: ${r.responseCode}") }
                }
            }
        }
    }
}
