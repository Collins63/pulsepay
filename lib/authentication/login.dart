import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/authentication/signup.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/licensing/license.dart';
import 'package:pulsepay/licensing/license_manager.dart';
import 'package:pulsepay/pointOfSale/pos.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final username = TextEditingController();
  final password = TextEditingController();

  bool isVisible = false;
  bool isLoginTrue = false;

  final db = DatabaseHelper();

  Future<void> saveUsername(String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role); // Overwrites any previous value
  }

  Future<void> login() async {
    var response =
        await db.login(Users(userName: username.text, userPassword: password.text));
    if (response == true) {
      final user = await db.getLoggedInUser(username.text);
      int isAdmin = user[0]['isAdmin'];
      int isCashier = user[0]['isCashier'];

      // First check license validity
      final validLicense = await LicenseManager.validateLicense();
      if (!validLicense) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LicenseRenewalScreen(
              onRenewed: () async {
                // After renewal, re-check license
                final valid = await LicenseManager.validateLicense();
                if (valid) {
                  _navigateUser(isAdmin, isCashier);
                }
              },
            ),
          ),
        );
        return;
      }

      // License valid, navigate user based on role
      _navigateUser(isAdmin, isCashier);
    } else {
      Get.snackbar(
        'Login Failed!',
        'Wrong Username Or Password',
        icon: const Icon(Icons.error, color: Colors.white),
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _navigateUser(int isAdmin, int isCashier) async {
    if (isAdmin == 1 && isCashier == 0) {
      if (!mounted) return;
      String role = 'Admin';
      db.setActiveUser(username.text);
      await saveUsername(username.text, role);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (isAdmin == 0 && isCashier == 1) {
      if (!mounted) return;
      String role = "Cashier";
      await saveUsername(username.text, role);
      db.setActiveUser(username.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Pos()),
      );
    }
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/login.PNG',
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login Below To Access Your Account",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Username field
                  TextFormField(
                    controller: username,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Username Required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: password,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password Required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Don't have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      GestureDetector(
                        onTap: () {
                          final TextEditingController passwordController =
                              TextEditingController();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Enter Password"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Please enter admin password"),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final enteredPassword =
                                          passwordController.text.trim();
                                      const String correctPassword =
                                          'admin123';
                                      if (enteredPassword == correctPassword) {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Signup(),
                                          ),
                                        );
                                      } else {
                                        Navigator.of(context).pop();
                                        Get.snackbar(
                                          'Denied!',
                                          'Wrong password',
                                          icon: const Icon(Icons.error,
                                              color: Colors.white),
                                          colorText: Colors.white,
                                          backgroundColor: Colors.red,
                                          snackPosition: SnackPosition.TOP,
                                        );
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Create",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isLoginTrue
                      ? const Text(
                          'Wrong Details',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

