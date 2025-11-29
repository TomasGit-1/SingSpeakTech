pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false

    // START: FlutterFire
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END

    // 🔥 Kotlin actualizado a 2.1.0 (recomendado para Flutter 3.35)
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
