import 'package:flutter/material.dart';
import 'package:pulsepay/authentication/login.dart';
import 'package:pulsepay/fiscalization/fiscal_tables.dart';
import 'package:pulsepay/forms/add_product.dart';
import 'package:pulsepay/forms/companyDetails.dart';
import 'package:pulsepay/forms/payment_methods.dart';
import 'package:pulsepay/forms/users.dart';
import 'package:pulsepay/home/fiscal_page.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/pointOfSale/pos.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Settings extends StatefulWidget{
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>{
  @override
  Widget build(BuildContext context){
    return  Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 19, 29),
      body: SafeArea(
        bottom: false,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                       const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome Back!",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text("User",
                            style: TextStyle(color: Colors.white, fontSize: 24 , fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton.outlined(onPressed: (){
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> const Login()));
                      }, icon: const Icon(Icons.logout_rounded , color: Colors.white,))
                    ],
                  ),
              ),
              const SizedBox(height: 20,),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Settings" ,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 24.0 , color: Colors.white ),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Get.to(() => const UsersPage());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.person , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('User Management', textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Get.to(()=> const FiscalTables());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.table_chart , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Fiscal Tables',textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddProduct()  ));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.settings , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('General Settings' ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Get.to(()=> const PaymentMethods());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.monetization_on_outlined , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Payment Methods' ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Get.to(()=> const Companydetails());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.card_membership_sharp , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Company Details' ,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.print_rounded , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Printer Settings' ,textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.check , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Account Terms',textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.rotate_left , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Shifts',textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.storage , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Backup',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.badge_outlined , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('License',textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> const UsersPage()));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.email , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('Email',textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: TextButton(onPressed: (){},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 , horizontal: 15),
                      child: Column(
                        children: [
                          Icon(Icons.question_mark_outlined , size: 40, color: Color.fromARGB(255, 14, 19, 29),),
                          Text('About Us' ,  textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 10 , color:Color.fromARGB(255, 14, 19, 29) ),)
                        ],
                      ),
                    )),
                  ),
                ],
              )
            ],
          )
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                icon: const Column(
                  children: [
                    Icon(Icons.home, color: Colors.grey,),
                    Text(
                        "Home",
                        style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
            ),
            IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FiscalPage()),
                  );
              },
              icon: const Column(
                children: [
                  Icon(Icons.list_alt, color: Colors.grey),
                  Text(
                    "Fiscalization",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            FloatingActionButton(
                onPressed: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Pos()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => MyLoans()),
                //);
              },
              icon: const Column(
                children: [
                  Icon(Icons.summarize, color: Colors.grey),
                  Text(
                    "Reporting",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => Profile()),
               // );
              },
              icon: const Column(
                children: [
                  Icon(Icons.settings, color: Colors.black),
                  Text(
                    "Settings",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}