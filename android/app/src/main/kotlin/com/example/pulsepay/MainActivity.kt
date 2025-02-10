package com.example.pulsepay
import org.bouncycastle.jce.provider.BouncyCastleProvider
import android.os.Bundle
import java.security.Security
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.security.KeyFactory
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.PKCS8EncodedKeySpec

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter/kotlin"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureBouncyCastleProvider()
    }
    private fun ensureBouncyCastleProvider() {
        val provider = Security.getProvider("BC")
        if (provider == null) {
            Security.addProvider(BouncyCastleProvider())  // Add BouncyCastle if not present
        } else {
            Security.removeProvider("BC")
            Security.addProvider(BouncyCastleProvider())  // Refresh provider
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "signData" -> {
                    val filePath: String? = call.argument("filePath")
                    val password: String? = call.argument("password")
                    val data: String? = call.argument("data")
                    if (filePath != null && password != null && data != null) {
                        val signedData = signData(filePath, password, data)
                        result.success(signedData)
                    } else {
                        result.error("INVALID_ARGS", "File path, password, or data is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun signData(filePath: String, password: String, data: String): String {
        return try {
            // Load the PKCS#12 keystore
            val fis = FileInputStream(filePath)
            val keystore = KeyStore.getInstance("PKCS12" ,"BC")
            keystore.load(fis, password.toCharArray())

            // Extract the private key (assuming the first alias contains it)
            val alias = keystore.aliases().nextElement()
            val privateKey = keystore.getKey(alias, password.toCharArray()) as PrivateKey

            // Sign data using SHA256withRSA
            val signature = Signature.getInstance("SHA256withRSA")
            signature.initSign(privateKey)
            signature.update(data.toByteArray(Charsets.UTF_8))
            val signedBytes = signature.sign()

            // Convert signed bytes to Base64 for easy transmission
            Base64.encodeToString(signedBytes, Base64.NO_WRAP)
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }
}
