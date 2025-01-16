import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/home/settings.dart';
import 'package:pulsepay/pointOfSale/pos.dart';

class FiscalPage extends StatefulWidget {
  const FiscalPage({super.key});

  @override
  State<FiscalPage> createState() => _FiscalPageState();
}

class _FiscalPageState extends State<FiscalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){Get.back();},
          icon: const Icon(Icons.arrow_circle_left_outlined , color: Colors.black ,size: 30,),
        ),
        centerTitle: true,
        title: const Text("Fiscal Configuration" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16),),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15,),
              Container(
                height:350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kDark,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0 ,top: 10.0),
                  child: ListView(
                    children: [
                      const Text("TAXPAYER NAME:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16),),
                      const SizedBox(height: 6,),
                      const Text("TAXPAYER TIN:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("VAT NUMBER:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("DEVICE ID:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("SERIAL NO:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("MODEL NAME:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("FSCAL DAY:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("TIME TO CLOSEDAY:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("RECEIPT COUNTER:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("RECEIPTS SUBMITTED:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      const SizedBox(height: 6,),
                      Text("RECEIPTS PENDING:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Get.to(()=> const HomePage());
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
                //Navigator.pushReplacement(
                  //context,
                  //MaterialPageRoute(builder: (context) => MyAccount()),
                //);
                Get.to(()=> const FiscalPage());
              },
              icon: const Column(
                children: [
                  Icon(Icons.list_alt, color: Colors.black),
                  Text(
                    "Fiscal",
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
               Get.to(()=> const Settings());
              },
              icon: const Column(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
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