// package com.example.pulsepay
// import org.bouncycastle.jce.provider.BouncyCastleProvider
// import android.os.Bundle
// import java.security.Security
// import android.util.Base64
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import java.io.FileInputStream
// import java.security.KeyFactory
// import java.security.KeyStore
// import java.security.PrivateKey
// import java.security.Signature
// import java.security.spec.PKCS8EncodedKeySpec

// class MainActivity : FlutterActivity() {
//     private val CHANNEL = "flutter/kotlin"

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         ensureBouncyCastleProvider()
//     }
//     private fun ensureBouncyCastleProvider() {
//         val provider = Security.getProvider("BC")
//         if (provider == null) {
//             Security.addProvider(BouncyCastleProvider())  // Add BouncyCastle if not present
//         } else {
//             Security.removeProvider("BC")
//             Security.addProvider(BouncyCastleProvider())  // Refresh provider
//         }
//     }

//     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//         super.configureFlutterEngine(flutterEngine)
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "signData" -> {
//                     val filePath: String? = call.argument("filePath")
//                     val password: String? = call.argument("password")
//                     val data: String? = call.argument("data")
//                     if (filePath != null && password != null && data != null) {
//                         val signedData = signData(filePath, password, data)
//                         result.success(signedData)
//                     } else {
//                         result.error("INVALID_ARGS", "File path, password, or data is null", null)
//                     }
//                 }
//                 else -> result.notImplemented()
//             }
//         }
//     }

//     private fun signData(filePath: String, password: String, data: String): String {
//         return try {
//             // Load the PKCS#12 keystore
//             val fis = FileInputStream(filePath)
//             val keystore = KeyStore.getInstance("PKCS12" ,"BC")
//             keystore.load(fis, password.toCharArray())

//             // Extract the private key (assuming the first alias contains it)
//             val alias = keystore.aliases().nextElement()
//             val privateKey = keystore.getKey(alias, password.toCharArray()) as PrivateKey

//             // Sign data using SHA256withRSA
//             val signature = Signature.getInstance("SHA256withRSA")
//             signature.initSign(privateKey)
//             signature.update(data.toByteArray(Charsets.UTF_8))
//             val signedBytes = signature.sign()

//             val md = MessageDigest.getInstance("MD5")
//             val digest = md.digest(signedBytes)
//             val hexString = digest.joinToString("") { "%02x".format(it) }
//             // Convert signed bytes to Base64 for easy transmission
//             //Base64.encodeToString(signedBytes, Base64.NO_WRAP)
//             mapOf(
//             "receiptDeviceSignature_signature_hex" to hexString,
//             "receiptDeviceSignature_signature" to Base64.encodeToString(signedBytes, Base64.NO_WRAP)
//             )
//         } catch (e: Exception) {
//             return "Error: ${e.message}"
//             //println("Error: ${e.message}")
//         }
//     }
// }
package com.example.pulsepay

import org.bouncycastle.jce.provider.BouncyCastleProvider
import android.os.Bundle
import java.security.Security
import java.security.MessageDigest
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
                        val signedData: Map<String, String> = signData(filePath, password, data)
                        result.success(signedData) // ✅ Correct return type
                    } else {
                        result.error("INVALID_ARGS", "File path, password, or data is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getFirst16CharsOfSignature(signature: String): String {
        if (signature.isBlank()) {
            throw IllegalArgumentException("Input must be a non-empty string.")
        }
    
        try {
            // Decode Base64 string to bytes
            val byteArray = Base64.decode(signature, Base64.DEFAULT)
    
            // Convert bytes to a hexadecimal string
            val hexStr = byteArray.joinToString("") { "%02x".format(it) }
    
            // Compute MD5 hash of the hexadecimal string
            val md = MessageDigest.getInstance("MD5")
            val md5Hash = md.digest(hexStr.toByteArray()).joinToString("") { "%02x".format(it) }
    
            // Return the first 16 characters of the MD5 hash
            return md5Hash.take(16)
    
        } catch (e: IllegalArgumentException) {
            throw IllegalArgumentException("Invalid Base64 string.", e)
        }
    }
    

    private fun signData(filePath: String, password: String, data: String): Map<String, String> {
        return try {
            // Load the PKCS#12 keystore
            val fis = FileInputStream(filePath)
            val keystore = KeyStore.getInstance("PKCS12", "BC")
            keystore.load(fis, password.toCharArray())

            // Extract the private key (assuming the first alias contains it)
            val alias = keystore.aliases().nextElement()
            val privateKey = keystore.getKey(alias, password.toCharArray()) as PrivateKey

             // **Pre-hash the data with SHA-256**
            val messageDigest = MessageDigest.getInstance("SHA-256")
            val hashedData = messageDigest.digest(data.toByteArray(Charsets.UTF_8))

            val signature = Signature.getInstance("NONEwithRSA") // Uses raw RSA signing
            signature.initSign(privateKey)
            signature.update(hashedData)
            val signedBytes = signature.sign()

            // Compute MD5 hash
            val md = MessageDigest.getInstance("MD5")
            val digest = md.digest(signedBytes)
            val hexString = digest.joinToString("") { byte -> "%02x".format(byte) }

            // Sign data using SHA256withRSA
            // val signature = Signature.getInstance("SHA256withRSA")
            // signature.initSign(privateKey)
            // signature.update(data.toByteArray(Charsets.UTF_8))
            // val signedBytes = signature.sign()

            // // Compute MD5 hash
            // val md = MessageDigest.getInstance("MD5")
            // val digest = md.digest(signedBytes)
            // val hexString = digest.joinToString("") { byte -> "%02x".format(byte) }

            // Convert signedBytes to Base64 string
            val base64Signature = Base64.encodeToString(signedBytes, Base64.NO_WRAP)

            // Compute first 16 chars of the MD5 hash from Base64 signature
            val first16Chars = getFirst16CharsOfSignature(base64Signature)

            // Return a Map instead of a string
            mapOf(
                "receiptDeviceSignature_signature_hex" to hexString,
                "receiptDeviceSignature_signature" to base64Signature,
                "receiptDeviceSignature_signature_md5_first16" to first16Chars
            )
        } catch (e: Exception) {
            mapOf("error" to e.message.orEmpty()) // ✅ Return an error in Map format
        }
    }
}
