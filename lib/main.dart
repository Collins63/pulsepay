import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/authentication/login.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const GetMaterialApp(home: MyApp(),) );
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
