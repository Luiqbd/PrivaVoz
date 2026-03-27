package com.privavoz.app;

/**
 * Whisper JNI Bridge
 * Provides native Whisper transcription functionality
 */
public class WhisperBridge {
    static {
        System.loadLibrary("whisper");
    }

    // Native methods
    public static native boolean nativeInit(String modelPath);
    public static native String nativeTranscribe(String audioPath);
    public static native void nativeFree();
    public static native String nativeGetVersion();

    /**
     * Initialize Whisper with model file
     * @param modelPath Path to the GGML model file
     * @return true if successful
     */
    public static boolean init(String modelPath) {
        return nativeInit(modelPath);
    }

    /**
     * Transcribe audio file
     * @param audioPath Path to audio file (m4a, wav, mp3)
     * @return JSON string with transcription result
     */
    public static String transcribe(String audioPath) {
        return nativeTranscribe(audioPath);
    }

    /**
     * Free resources
     */
    public static void free() {
        nativeFree();
    }

    /**
     * Get Whisper version
     */
    public static String getVersion() {
        return nativeGetVersion();
    }
}