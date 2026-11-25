import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

// Firebase Analytics włącza się automatycznie, gdy dodasz plik app/google-services.json z konsoli Firebase.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val testAdmobAppId = "ca-app-pub-3940256099942544~3347511713"
val testRewardedId = "ca-app-pub-3940256099942544/5224354917"
val admobAppId = (findProperty("admobAppId") as String?) ?: testAdmobAppId
val admobRewardedId = (findProperty("admobRewardedId") as String?) ?: testRewardedId

// Podpis wersji do Google Play – z zmiennych środowiskowych (CI) albo z ~/.gradle/gradle.properties.
fun secret(name: String): String? = System.getenv(name) ?: (findProperty(name) as String?)

android {
    namespace = "com.twojafirma.imperiumkopalni"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.twojafirma.imperiumkopalni"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        create("release") {
            val ks = secret("KEYSTORE_FILE")
            if (ks != null) {
                storeFile = file(ks)
                storePassword = secret("KEYSTORE_PASSWORD")
                keyAlias = secret("KEY_ALIAS")
                keyPassword = secret("KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        debug {
            // Wersja testowa zawsze używa reklam testowych Google.
            manifestPlaceholders["admobAppId"] = testAdmobAppId
            buildConfigField("String", "REWARDED_ID", "\"$testRewardedId\"")
        }
        release {
            isMinifyEnabled = false
            manifestPlaceholders["admobAppId"] = admobAppId
            buildConfigField("String", "REWARDED_ID", "\"$admobRewardedId\"")
            val release = signingConfigs.getByName("release")
            if (release.storeFile != null) signingConfig = release
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Gra (HTML/JS) jest wspólna z wersją przeglądarkową – leży w ../game-web.
    sourceSets {
        getByName("main") {
            assets.srcDirs("src/main/assets", rootProject.file("../game-web"))
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.16.0")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.activity:activity-ktx:1.10.1")
    implementation("androidx.webkit:webkit:1.12.1")
    implementation("com.android.billingclient:billing:8.0.0")
    implementation("com.google.android.gms:play-services-ads:24.0.0")
    implementation("com.google.android.ump:user-messaging-platform:3.1.0")
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
