package com.privavoz.app;

/**
 * Llama JNI Bridge
 * Provides native Llama/TinyLlama text generation functionality
 */
public class LlamaBridge {
    static {
        System.loadLibrary("llama");
    }

    // Native methods
    public static native boolean nativeInit(String modelPath);
    public static native String nativeGenerate(String prompt, int maxTokens);
    public static native String nativeChat(String systemPrompt, String userMessage);
    public static native void nativeFree();
    public static native String nativeGetVersion();

    /**
     * Initialize Llama with model file
     * @param modelPath Path to the GGUF model file
     * @return true if successful
     */
    public static boolean init(String modelPath) {
        return nativeInit(modelPath);
    }

    /**
     * Generate text from prompt
     * @param prompt Input prompt
     * @param maxTokens Maximum tokens to generate
     * @return Generated text
     */
    public static String generate(String prompt, int maxTokens) {
        return nativeGenerate(prompt, maxTokens);
    }

    /**
     * Chat completion
     * @param systemPrompt System prompt
     * @param userMessage User message
     * @return Generated response
     */
    public static String chat(String systemPrompt, String userMessage) {
        return nativeChat(systemPrompt, userMessage);
    }

    /**
     * Free resources
     */
    public static void free() {
        nativeFree();
    }

    /**
     * Get Llama version
     */
    public static String getVersion() {
        return nativeGetVersion();
    }
}