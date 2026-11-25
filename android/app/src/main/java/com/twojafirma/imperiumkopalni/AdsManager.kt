package com.twojafirma.imperiumkopalni

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Reklamy za nagrodę (AdMob) + okno zgody RODO (Google UMP), wymagane w UE.
 */
class AdsManager(
    private val activity: MainActivity,
    private val callJs: (String, List<Any?>, ((String?) -> Unit)?) -> Unit,
) {
    private val initialized = AtomicBoolean(false)
    private val handler = Handler(Looper.getMainLooper())
    private var rewarded: RewardedAd? = null
    private var loading = false

    fun start() {
        val consent = UserMessagingPlatform.getConsentInformation(activity)
        val params = ConsentRequestParameters.Builder().build()
        consent.requestConsentInfoUpdate(
            activity,
            params,
            {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { error ->
                    if (error != null) Log.w(TAG, "Consent form: ${error.message}")
                    if (consent.canRequestAds()) initAds()
                }
            },
            { error ->
                Log.w(TAG, "Consent update: ${error.message}")
                if (consent.canRequestAds()) initAds()
            },
        )
        if (consent.canRequestAds()) initAds()
    }

    private fun initAds() {
        if (!initialized.compareAndSet(false, true)) return
        MobileAds.initialize(activity) { load() }
    }

    private fun load() {
        if (loading || rewarded != null || !initialized.get()) return
        loading = true
        RewardedAd.load(activity, BuildConfig.REWARDED_ID, AdRequest.Builder().build(),
            object : RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    loading = false
                    rewarded = ad
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    loading = false
                    rewarded = null
                    Log.w(TAG, "Rewarded load failed: ${error.message}")
                    handler.postDelayed({ load() }, 30_000L)
                }
            })
    }

    fun showRewarded(kind: String) {
        val ad = rewarded
        if (ad == null) {
            callJs("onAdFailed", listOf(kind), null)
            load()
            return
        }
        var earned = false
        ad.fullScreenContentCallback = object : FullScreenContentCallback() {
            override fun onAdDismissedFullScreenContent() {
                rewarded = null
                load()
                callJs(if (earned) "onAdReward" else "onAdCancelled", listOf(kind), null)
            }

            override fun onAdFailedToShowFullScreenContent(error: AdError) {
                rewarded = null
                load()
                callJs("onAdFailed", listOf(kind), null)
            }
        }
        ad.show(activity) { earned = true }
    }

    companion object {
        private const val TAG = "ImperiumAds"
    }
}
