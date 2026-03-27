plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

def flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

android {
    namespace "com.privavoz.app"
    compileSdk 34
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        main {
            jniLibs.srcDirs = ["libs"]
        }
    }

    defaultConfig {
        applicationId "com.privavoz.app"
        minSdk 24
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        
        ndk {
            abiFilters ["armeabi-v7a", "arm64-v8a", "x86", "x86_64"]
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
        }
    }
    
    // Native code build
    externalNativeBuild {
        cmake {
            path file("src/main/cpp/CMakeLists.txt")
            version "3.18.1"
        }
    }
    
    // Bundled libraries
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs += ["src/main/cpp/libs"]
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    // Core
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "com.google.android.material:material:1.11.0"
    
    // Lifecycle
    implementation "androidx.lifecycle:lifecycle-runtime-ktx:2.7.0"
    implementation "androidx.lifecycle:lifecycle-service:2.7.0"
    
    // Biometric
    implementation "androidx.biometric:biometric:1.1.0"
}