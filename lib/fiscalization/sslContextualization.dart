import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SSLContextProvider {
  Future<bool> requestStoragePermission() async {
  if (await Permission.storage.isGranted) {
    return true;
  }
  
  var status = await Permission.storage.request();
  return status.isGranted;
}

  Future<SecurityContext> createSSLContext() async {
    // Get the local directory for app files
    Directory? appDir = await getApplicationDocumentsDirectory();
    bool hasPermission = await requestStoragePermission();
    // Construct the correct path to the keystore
    String keystorePath = "/storage/emulated/0/Pulse/Configurations/testwelleast_T_certificate.p12";
    String keystorePassword = "testwelleast123"; // Replace with actual password
    SecurityContext securityContext = SecurityContext.defaultContext;
    

if (!hasPermission) {
    print("Permission denied. Cannot access external storage.");
  }

  File keystoreFile = File(keystorePath);
  if (!keystoreFile.existsSync()) {
    print("Keystore file not found at: $keystorePath");
  }

  print("Keystore file exists and is accessible!");

    try {
      File keystoreFile = File(keystorePath);
      if (!keystoreFile.existsSync()) {
        throw Exception("Keystore file not found at: $keystorePath");
      }

      securityContext.useCertificateChain(keystorePath, password: keystorePassword);
      securityContext.usePrivateKey(keystorePath, password: keystorePassword);

      print("SSL Context parameterization complete.");
    } catch (e) {
      print("Error initializing SSL Context: $e");
    }

    return securityContext;
  }
}