package com.twojafirma.imperiumkopalni

import android.content.Context
import android.os.Bundle
import android.util.Log
import com.google.firebase.analytics.FirebaseAnalytics
import org.json.JSONObject

/**
 * Zdarzenia z gry → Firebase Analytics.
 * Bez pliku google-services.json Firebase jest nieaktywny, a zdarzenia trafiają tylko do Logcat.
 */
class Analytics(context: Context) {

    private val firebase: FirebaseAnalytics? =
        runCatching { FirebaseAnalytics.getInstance(context.applicationContext) }.getOrNull()

    fun log(name: String, paramsJson: String) {
        val event = name.replace(Regex("[^A-Za-z0-9_]"), "_").take(40)
        val bundle = Bundle()
        runCatching {
            val json = JSONObject(paramsJson)
            for (key in json.keys()) {
                val k = key.replace(Regex("[^A-Za-z0-9_]"), "_").take(40)
                when (val v = json.get(key)) {
                    is Int -> bundle.putLong(k, v.toLong())
                    is Long -> bundle.putLong(k, v)
                    is Number -> bundle.putDouble(k, v.toDouble())
                    is Boolean -> bundle.putString(k, v.toString())
                    else -> bundle.putString(k, v.toString().take(100))
                }
            }
        }
        Log.d("ImperiumAnalytics", "$event $paramsJson")
        runCatching { firebase?.logEvent(event, bundle) }
    }
}
