import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pulsepay/authentication/login.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const GetMaterialApp(home: MyApp(),) );
}
const MethodChannel _channel = MethodChannel('flutter/kotlin');
Future<String> signData(String filePath, String password, String data) async {
  try {
    final String signedData = await _channel.invokeMethod('signData', {
      'filePath': filePath,
      'password': password,
      'data': data,
    });
    return signedData;
  } on PlatformException catch (e) {
    return "Error: ${e.message}";
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
