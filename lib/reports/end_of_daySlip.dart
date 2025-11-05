import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/services/printerService.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map<String, dynamic>> soldProducts = [];
  bool _isConnected = false;
  bool _isPrinting = false;
  String _printerStatus = 'Checking...';
  String? companyName;
  String? companyAddress;
  String? companyPhone;
  bool hasBluetoothPrinter = false;
  final printerService = PrinterService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializePrinter();
    getDate();
    getSalesData();
    getCompanyDetails();
    loadUsers();
    getSoldProducts();
    getGeneralSettings();
  }
  
  // get today's date
  void getDate(){
    DateTime now  = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd").format(now);
    todayDate = formattedDate ;
  }

  Future<void> getGeneralSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasBluetoothPrinter = prefs.getBool('hasBluetoothPrinter') ?? false;
    });
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

  void getSoldProducts() async{
    final data = await dbHelper.getSoldProducts();
    setState(() {
      soldProducts = data;
    });
    print(soldProducts);
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
    await printerService.loadSavedPrinter(); // ensures printer is loaded
    final printer = printerService.printer;

    if(hasBluetoothPrinter = false){
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
    }else{
      printer.printNewLine();
      printer.printCustom("$companyName", 2, 1);
      printer.printCustom("$companyAddress", 2, 1);
      printer.printCustom("$companyPhone", 2, 1);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("---END OF DAY REPORT---", 3, 1);
      printer.printCustom("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}", 1, 0);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("Cash Summary All Users:", 3, 1);
      printer.printCustom("USD: \$${salesData['usdTotal']}", 1, 0);
      printer.printCustom("ZWG: \$${salesData['zwgTotal']}", 1, 0);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("Cash Total(USD) : $cashTotal}", 1, 0);
      printer.paperCut();
    }
    //await SunmiPrinter.exitTransactionPrint(true);
  }

  String? selectedUser;
  List<String> users = [];

  Future<List<String>> fetchUsers() async{
    final List<Map<String, dynamic>> users = await dbHelper.getAllUsers();
    return users.map((row) => row['userName'] as String).toList();
  }

  Future<void> loadUsers()async{
    final results = await fetchUsers();
    setState(() {
      users = results;
    });
  }

  Future<void>loadUserTotals() async{
    final userSalesData = await dbHelper.getAllUserSales(selectedUser);
    List<Map<String, dynamic>> userSales = userSalesData
      .where((invoice) => invoice['doneBY'] == selectedUser)
      .toList();
    Map<String, Map<String, double>> totalsByCurrency = {};

    for (var sale in userSales) {
      String currency = sale['currency'];

      double amount = (sale['totalAmount'] ?? 0).toDouble();
      double tax = (sale['totalTax'] ?? 0).toDouble();

      if (!totalsByCurrency.containsKey(currency)) {
        totalsByCurrency[currency] = {
          'totalAmount': 0.0,
          'totalTax': 0.0,
        };
      }
      totalsByCurrency[currency]!['totalAmount'] =
          (totalsByCurrency[currency]!['totalAmount'] ?? 0) + amount;
      totalsByCurrency[currency]!['totalTax'] =
          (totalsByCurrency[currency]!['totalTax'] ?? 0) + tax;
    }
    print("Sales summary for user: $selectedUser\n");
    await printerService.loadSavedPrinter(); // ensures printer is loaded
    final printer = printerService.printer;

    if(hasBluetoothPrinter = false){
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('$companyName\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
      await SunmiPrinter.printText('$companyAddress\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
      await SunmiPrinter.printText('$companyPhone\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
      await SunmiPrinter.printText('--- User Day Report ---\n', style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true));
      await SunmiPrinter.printText('-----------------------------\n');
      await SunmiPrinter.printText('-----------------------------\n');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}\n', style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true));
      await SunmiPrinter.printText('User: $selectedUser', style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, bold: true));
      await SunmiPrinter.printText('-----------------------------\n');
      await SunmiPrinter.printText('-----------------------------\n');
      await SunmiPrinter.printText('N0. of transactions: ${userSalesData.length}\n');
      await SunmiPrinter.printText('-----------------------------\n');
      await SunmiPrinter.printText('-----------------------------\n');
      totalsByCurrency.forEach((currency, totals) async {
        print('Currency: $currency');
        print('  Total Amount: ${totals['totalAmount']?.toStringAsFixed(2)}');
        print('  Total Tax: ${totals['totalTax']?.toStringAsFixed(2)}\n');
        await SunmiPrinter.printText('Currency: $currency\n');
        await SunmiPrinter.printText('Total Amount: $currency-${totals['totalAmount']?.toStringAsFixed(2)}\n');
        await SunmiPrinter.printText('Total Tax: $currency-${totals['totalTax']?.toStringAsFixed(2)}\n');
        await SunmiPrinter.lineWrap(2);
        await SunmiPrinter.cutPaper();
      });
      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.cutPaper();
    }else{
      printer.printNewLine();
      printer.printCustom("$companyName", 2, 1);
      printer.printCustom("$companyAddress", 2, 1);
      printer.printCustom("$companyPhone", 2, 1);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("---END OF DAY REPORT---", 3, 1);
      printer.printCustom("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}", 1, 0);
      printer.printCustom("User: $selectedUser", 1, 0);
      printer.printCustom("N0. of transactions: ${userSalesData.length}", 1, 0);
      printer.printCustom("================================", 1, 0);
      totalsByCurrency.forEach((currency, totals) async{
        printer.printCustom("Currency: $currency", 1, 0);
        printer.printCustom("Total Amount: $currency-${totals['totalAmount']?.toStringAsFixed(2)}", 1, 0);
        printer.printCustom("Total Tax: $currency-${totals['totalTax']?.toStringAsFixed(2)}", 1, 0);
      });
      printer.printCustom("================================", 1, 0);
      printer.paperCut();
    }

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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50,),
              const Center(child: Image(image: AssetImage('assets/print.gif'),)),
              const SizedBox(height: 20,),
              Container(
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.shade400
                ),
                child: Center(
                  child: Text(
                    todayDate, style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height:20,),
              const Heading(text: 'Print for all',),
              const SizedBox(height: 10,),
              CustomOutlineBtn(
                text: "Print",
                color: Colors.blue,
                color2: Colors.blue,
                height: 50,
                onTap: (){
                  printEndOfDayReport();
                },
              ),
              const SizedBox(height: 30,),
              const Heading(text: 'Print for user',),
              const SizedBox(height: 20,),
              Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // shadow color
                      spreadRadius: 4, // how much the shadow spreads
                      blurRadius: 10,  // how soft the shadow is
                      offset: Offset(0, 6), // horizontal and vertical offset
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DropdownButton<String>(
                    menuWidth: 200,
                    hint: Text("Select User"),
                    value: selectedUser,
                    onChanged: (value)async{
                      setState(() {
                        selectedUser= value;
                      });
                      await loadUserTotals();
                    },
                    items: users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user,
                        child: Text(user),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              const Heading(text: "Products Sold"),
              const SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // shadow color
                      spreadRadius: 4, // how much the shadow spreads
                      blurRadius: 10,  // how soft the shadow is
                      offset: const Offset(0, 6), // horizontal and vertical offset
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: soldProducts.length,
                    itemBuilder: (context, index){
                      final product = soldProducts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0 , horizontal: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white
                        ),
                        child: ListTile(
                          title: Text(product['productName']),
                          subtitle: Text("Quantity: ${product['total_quantity_sold']}"),
                          trailing: Text("\$${product['total_sales_base']}"),
                        ),
                      );
                    }
                  ),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}