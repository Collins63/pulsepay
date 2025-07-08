import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class EndOfDayslip extends StatefulWidget {
  const EndOfDayslip({super.key});

  @override
  State<EndOfDayslip> createState() => _EndOfDayslipState();
}

class _EndOfDayslipState extends State<EndOfDayslip> {

  String todayDate = "" ;
  Map<String, dynamic> salesData = {};
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _isConnected = false;
  bool _isPrinting = false;
  String _printerStatus = 'Checking...';
  String? companyName;
  String? companyAddress;
  String? companyPhone;
  
  // get today's date
  void getDate(){
    DateTime now  = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd").format(now);
    todayDate = formattedDate ;
  }

  //Get sales data summary

  void getSalesData()async{
    final data = await dbHelper.getSalesSummary();
    setState(() {
      salesData = data;
    });
  }

  Future<void> _initializePrinter() async {
    try {
      // Initialize the printer first
      await SunmiPrinter.initPrinter();
      
      // Check if printer is available
      await SunmiPrinter.bindingPrinter();
      
      setState(() {
        _isConnected = true;
        _printerStatus = 'Sunmi Printer Ready';
      });
      print("Printer Initialized Successfully");
    } catch (e) {
      print('Printer initialization error: $e');
      setState(() {
        _isConnected = false;
        _printerStatus = 'Printer initialization failed: ${e.toString()}';
      });
    }
  }

  //Get company details
  void getCompanyDetails() async{
    final companyDetails = await dbHelper.getCompanyDetails();
    if (companyDetails != null) {
      setState(() {
        companyName = companyDetails[0]['company'].toString();
        companyAddress = companyDetails[0]['address'].toString();
        companyPhone = companyDetails[0]['tel'].toString();
      });
    } else {
      print("No company details found");
    }
  }

  //print end of day slip for all users
  Future<void> printEndOfDayReport() async {
    
    final zwgRate= await dbHelper.getCurrencyAndRate('ZWG');
    final zarRate = await dbHelper.getCurrencyAndRate('ZAR');

    double zwgRateValute = zwgRate[0]['rate'] ?? 0.0;
    //double zarRateValue = zarRate[0]['rate'] ?? 0.0;

    double zwgtoUsd = salesData['zwgTotal'] / zwgRateValute;
   // double zarToUsd = salesData['zarTotal'] / zarRateValue;

    double cashTotal = salesData['usdTotal'] + zwgtoUsd ;

    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('$companyName\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
    await SunmiPrinter.printText('$companyAddress\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
    await SunmiPrinter.printText('$companyPhone\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
    await SunmiPrinter.printText('--- End of Day Report ---\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));

    await SunmiPrinter.printText('-----------------------------\n');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}\n', style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true));
    await SunmiPrinter.printText('-----------------------------\n');

    await SunmiPrinter.printText('\nCash Summary All Users:\n', style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true));
    await SunmiPrinter.printText('USD: \$${salesData['usdTotal']}\n');
    await SunmiPrinter.printText('ZWG: \$${salesData['zwgTotal']}\n');
    //await SunmiPrinter.printText('ZAR: \$${salesData['zarTotal']}\n');
    await SunmiPrinter.printText('-----------------------------\n');

    await SunmiPrinter.printText('-----------------------------\n');
    await SunmiPrinter.printText('Cash Total(USD) : $cashTotal}\n', style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true));

    await SunmiPrinter.lineWrap(2);
    await SunmiPrinter.cutPaper();
    //await SunmiPrinter.exitTransactionPrint(true);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializePrinter();
    getDate();
    getSalesData();
    getCompanyDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("End Of Day Slip" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
                )
              ),
        )
      ),
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50,),
            const Center(child: ReusableText(text: "Print Options", style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500))),
            const SizedBox(height: 20,),
            
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.green
              ),
              child: Center(
                child: Text(
                  todayDate, style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height:20,),
            CustomOutlineBtn(
              text: "Print For All",
              color: kDark,
              color2: kDark,
              height: 50,
              onTap: (){
                printEndOfDayReport();
              },
            ),
            const SizedBox(height: 20,),
            const Center(child: ReusableText(text: "Print For User", style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500))),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color(0xffC5C5C5),
                )
              ),
            ),
            CustomOutlineBtn(
              text: "Print For User",
              color: kDark,
              color2: kDark,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}