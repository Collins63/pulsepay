import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class LicenseManager {
  static const String secret = "license@constraDepot123"; // must match Python
  static const String licenseFileName = "license.key";

  static Future<File> _getLicenseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$licenseFileName");
  }

  static Future<void> saveLicense(String content) async {
    final file = await _getLicenseFile();
    await file.writeAsString(content);
  }

  static Future<bool> validateLicense() async {
    try {
      final file = await _getLicenseFile();
      if (!await file.exists()) return false;

      final content = await file.readAsString();

      final lines = content
          .split('\n')
          .where((l) => !l.contains("BEGIN") && !l.contains("END"))
          .toList();

      if (lines.isEmpty) return false;

      final parts = lines.first.split("|");
      if (parts.length != 3) return false;

      final userId = parts[0];
      final expiryDate = parts[1];
      final licenseKey = parts[2];

      final raw = "$userId-$expiryDate-$secret";
      final expectedHash = sha256.convert(utf8.encode(raw)).toString();

      if (licenseKey != expectedHash) return false;

      final now = DateTime.now();
      final expiry = DateTime.parse(expiryDate);
      if (now.isAfter(expiry)) return false;

      return true;
    } catch (_) {
      return false;
    }
  }
}
