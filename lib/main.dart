import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pulsepay/authentication/login.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const GetMaterialApp(home: MyApp(),) );
}
const MethodChannel _channel = MethodChannel('flutter/kotlin');
// Future<String> signData(String filePath, String password, String data) async {
//   try {
//     final String signedData = await _channel.invokeMethod('signData', {
//       'filePath': filePath,
//       'password': password,
//       'data': data,
//     });
//     return signedData;
//   } on PlatformException catch (e) {
//     return "Error: ${e.message}";
//   }
// }
Future<Map<String, String>> signData(String filePath, String password, String data) async {
  try {
    // final Map<dynamic, dynamic>? result = await _channel.invokeMethod('signData', {
    //   'filePath': filePath,
    //   'password': password,
    //   'data': data,
    // });

    // if (result != null) {
    //   return {
    //     "receiptDeviceSignature_signature_hex": result['receiptDeviceSignature_signature_hex'] ?? "",
    //     "receiptDeviceSignature_signature": result['receiptDeviceSignature_signature'] ?? "",
    //   };
    final Map<String, String> signedDataMap = Map<String, String>.from(await _channel.invokeMethod('signData', {
      'filePath': filePath,
      'password': password,
      'data': data,
    }));

    // Decode JSON response into a Map
    //final Map<String, String> signedDataMap = jsonDecode(signedDataString);

    return signedDataMap;
  } on PlatformException catch (e) {
    print(e.message);
    return {
      "error": "Error: ${e.message}",
    };
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Pay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 243, 243, 243)),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
