package com.twojafirma.imperiumkopalni

import android.webkit.JavascriptInterface

/**
 * Metody dostępne w grze jako window.AndroidBridge.*
 * Wywoływane z wątku WebView, dlatego przełączamy się na wątek UI.
 */
class GameBridge(private val activity: MainActivity) {

    @JavascriptInterface
    fun ready() = activity.runOnUiThread { activity.onGameReady() }

    @JavascriptInterface
    fun buy(productId: String) = activity.runOnUiThread { activity.billing.buy(productId) }

    @JavascriptInterface
    fun restore() = activity.runOnUiThread { activity.billing.restore() }

    @JavascriptInterface
    fun showRewarded(kind: String) = activity.runOnUiThread { activity.ads.showRewarded(kind) }

    @JavascriptInterface
    fun track(name: String, paramsJson: String) = activity.analytics.log(name, paramsJson)

    @JavascriptInterface
    fun openUrl(url: String) = activity.runOnUiThread { activity.openUrl(url) }
}
