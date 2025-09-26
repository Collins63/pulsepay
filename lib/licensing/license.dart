import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/authentication/login.dart';
import 'package:pulsepay/licensing/license_manager.dart';

class LicenseRenewalScreen extends StatefulWidget {
  final VoidCallback onRenewed;

  const LicenseRenewalScreen({super.key, required this.onRenewed});

  @override
  State<LicenseRenewalScreen> createState() => _LicenseRenewalScreenState();
}

class _LicenseRenewalScreenState extends State<LicenseRenewalScreen> {
  final _controller = TextEditingController();
  String? _error;

  Future<void> _saveLicense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = "Please paste a license key");
      return;
    }

    await LicenseManager.saveLicense(text);

    final valid = await LicenseManager.validateLicense();
    if (valid) {
      widget.onRenewed();
      Get.snackbar(
        "Success",
        "License is valid",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.message, color: Colors.white,)
      );
    } else {
      setState(() => _error = "Invalid or expired license");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("License Renewal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const Text(
                "Your license has expired or is invalid.\n"
                "Paste your new license key below:",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "-----BEGIN LICENSE-----\nuser|date|hash\n-----END LICENSE-----",
                  border: OutlineInputBorder(),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLicense,
                child: const Text("Activate License"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Login() ));
                },
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
