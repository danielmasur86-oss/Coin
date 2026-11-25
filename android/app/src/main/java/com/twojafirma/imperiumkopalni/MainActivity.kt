package com.twojafirma.imperiumkopalni

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.webkit.WebViewAssetLoader
import androidx.webkit.WebViewClientCompat
import org.json.JSONObject

/**
 * Jedyny ekran aplikacji: WebView z grą (assets/index.html) + natywne usługi:
 * Google Play Billing, AdMob (reklamy za nagrodę), zgoda RODO (UMP) i Firebase Analytics.
 */
class MainActivity : AppCompatActivity() {

    private lateinit var web: WebView
    lateinit var billing: BillingManager
        private set
    lateinit var ads: AdsManager
        private set
    lateinit var analytics: Analytics
        private set

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)

        val root = FrameLayout(this).apply { setBackgroundColor(Color.parseColor("#1F6FE0")) }
        web = WebView(this)
        root.addView(web, FrameLayout.LayoutParams(-1, -1))
        setContentView(root)
        WindowCompat.getInsetsController(window, root).isAppearanceLightStatusBars = false

        // Gra nie wchodzi pod pasek stanu ani pasek nawigacji.
        ViewCompat.setOnApplyWindowInsetsListener(root) { v, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom)
            WindowInsetsCompat.CONSUMED
        }

        analytics = Analytics(this)
        billing = BillingManager(this, ::callJs)
        ads = AdsManager(this, ::callJs)

        val loader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()

        web.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            mediaPlaybackRequiresUserGesture = true
            setSupportZoom(false)
        }
        web.webViewClient = object : WebViewClientCompat() {
            override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? =
                loader.shouldInterceptRequest(request.url)

            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                if (request.url.host == ASSET_HOST) return false
                // Linki zewnętrzne (np. polityka prywatności) otwieramy w przeglądarce.
                runCatching { startActivity(Intent(Intent.ACTION_VIEW, request.url)) }
                return true
            }
        }
        web.addJavascriptInterface(GameBridge(this), "AndroidBridge")
        web.loadUrl("https://$ASSET_HOST/assets/index.html")

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                web.evaluateJavascript("window.onBack ? window.onBack() : false") { handled ->
                    if (handled != "true") {
                        isEnabled = false
                        onBackPressedDispatcher.onBackPressed()
                        isEnabled = true
                    }
                }
            }
        })

        billing.start()
        ads.start()
    }

    /** Wywoływane przez grę, gdy jest gotowa – wysyłamy ceny i zakupione ulepszenia. */
    fun onGameReady() {
        billing.pushStateToGame()
    }

    /** Wywołanie funkcji JS w grze, np. callJs("onPurchase", listOf(id, token)). */
    fun callJs(function: String, args: List<Any?>, onResult: ((String?) -> Unit)? = null) {
        val argList = args.joinToString(",") { arg ->
            when (arg) {
                null -> "null"
                is Number, is Boolean -> arg.toString()
                is JSONObject -> arg.toString()
                else -> JSONObject.quote(arg.toString())
            }
        }
        val script = "window.$function ? window.$function($argList) : null"
        runOnUiThread { web.evaluateJavascript(script) { onResult?.invoke(it) } }
    }

    override fun onPause() {
        web.evaluateJavascript("window.onAppPause && window.onAppPause()", null)
        web.onPause()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        web.onResume()
        web.evaluateJavascript("window.onAppResume && window.onAppResume()", null)
        billing.refreshPurchases()
    }

    override fun onDestroy() {
        billing.end()
        web.destroy()
        super.onDestroy()
    }

    fun openUrl(url: String) {
        runCatching { startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) }
    }

    companion object {
        const val ASSET_HOST = "appassets.androidplatform.net"
    }
}
