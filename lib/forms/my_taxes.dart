import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/reports/sales_report.dart';

class MyTaxes extends StatefulWidget {
  const MyTaxes({super.key});

  @override
  State<MyTaxes> createState() => _MyTaxesState();
}

class _MyTaxesState extends State<MyTaxes> {

  DatabaseHelper dbHepler = DatabaseHelper();
  double totalTaxAmount = 0.0;
  late Future<Map<String, double>> taxIdTotals;
  List<Map<String, dynamic>> topProducts = [];
  Map<String, dynamic> monthlyTaxDetails = {};
  Map<String, dynamic> monthlyTaxDetailsUSD = {};
  List<Map<String, dynamic>> receiptsPending = [];
  List<String> currencies = [];
  double taxTotal1 = 0.0;
  double taxTotal2 = 0.0;
  double taxTotal3 = 0.0;
  double tax1Percent = 0.0;
  double tax2Percent = 0.0;
  double tax3Percent = 0.0;
  double monthTotalTaxAmount = 0.0;
  double monthTotalTaxAmountUSD = 0.0;
  int? usdCount;
  int? zwgCount;

  String? selectedCurrency;


  @override
  void initState() {
    loadCurrencies();
    super.initState();
    getTotalTax();
    loadTaxTotals();
   // percentageCalculator();
   dbHepler.getTopProductsByQuantity().then((value) {
     setState(() {
       topProducts = value;
     });
   });

   dbHepler.getCurrentMonthTaxDetails().then((value) {
     setState(() {
        monthlyTaxDetails = value;
        double getMonthTaxTotal = monthlyTaxDetails['totalTaxAmount'] ?? 0.0;
        monthTotalTaxAmount = double.parse(getMonthTaxTotal.toStringAsFixed(2));
        zwgCount = monthlyTaxDetails['receiptCount'];
     });
   });
   dbHepler.getCurrentMonthTaxDetailsUSD().then((value) {
     setState(() {
       monthlyTaxDetailsUSD = value;
       double getMonthTaxTotal = monthlyTaxDetailsUSD['totalTaxAmount'] ?? 0.0;
        monthTotalTaxAmountUSD = double.parse(getMonthTaxTotal.toStringAsFixed(2));
        usdCount = monthlyTaxDetailsUSD['receiptCount'];
     });
   });

    dbHepler.getReceiptsPending().then((value) {
      setState(() {
        receiptsPending = value;
      });
    });
  }

  Future<List<String>> fetchCurrencies() async{
    final List<Map<String, dynamic>> currencies = await dbHepler.getAllCurrencies();
    print(currencies);
    return currencies.map((row) => row['currency'] as String).toList();
  }

  Future<void> loadCurrencies()async{
    final results = await fetchCurrencies();
    setState(() {
      currencies = results;
    });
  }


  void loadTaxTotals() async{
    Map<String, double> totals = await getTaxTotalsByID();
    setState(() {
      taxTotal1 = totals["1"] ?? 0.0;
      taxTotal2 = totals["2"] ?? 0.0;
      taxTotal3 = totals["3"] ?? 0.0;
    });
    percentageCalculator();
  }

  void percentageCalculator(){
    double totalTaxAmount = taxTotal1 + taxTotal2 + taxTotal3;
    if(totalTaxAmount > 0){
      double bRtax1Percent = (taxTotal1 / totalTaxAmount) * 100;
      double bRtax2Percent = (taxTotal2 / totalTaxAmount) * 100;
      double bRtax3Percent = (taxTotal3 / totalTaxAmount) * 100;
      tax1Percent = double.parse(bRtax1Percent.toStringAsFixed(2));
      tax2Percent = double.parse(bRtax2Percent.toStringAsFixed(2));
      tax3Percent = double.parse(bRtax3Percent.toStringAsFixed(2));
    }
    else{
      tax1Percent = 0.0;
      tax2Percent = 0.0;
      tax3Percent = 0.0;
    }
    print("total tax amount is $totalTaxAmount");
  }
  
  getTotalTax() async{
    final List<Map<String, dynamic>> result = await dbHepler.getTotalTaxAmount(selectedCurrency);
    if(result.isNotEmpty && result.first['totalTaxAmount'] != null){
      setState(() {
        double rtotalTaxAmount = result.first['totalTaxAmount'];
        totalTaxAmount =  double.parse(rtotalTaxAmount.toStringAsFixed(2));
        //totalTaxAmount.round();
      });
    }
  }
  //756.52

  Future<Map<String, double>>  getTaxTotalsByID() async{
    final receipts = await dbHepler.getAllFiscalInvoice(selectedCurrency);
    Map<String, double> totals = {
      "1": 0.0,
      "2": 0.0,
      "3": 0.0,
    };
    for(var receipt in receipts){
      final jsonBody = receipt['receiptJsonbody'];
      //print(jsonBody);
      if (jsonBody== null) continue;
      try {
        final Map<String , dynamic> receiptData = jsonDecode(jsonBody);
        if(receiptData['receipt']['receiptTaxes'] is List){
          List<dynamic> taxes = receiptData['receipt']['receiptTaxes'];
          //print(taxes);
          for(var tax in taxes){
            if(tax is Map<String, dynamic>){
              final String taxID = tax['taxID'] ?? '';
              if(totals.containsKey(taxID)){
                double amount = 0.0;
                if (tax['salesAmountWithTax'] is String){
                  amount = double.tryParse(tax['salesAmountWithTax']) ?? 0.0;
                }
                else if (tax['salesAmountWithTax'] is num){
                  amount = (tax['salesAmountWithTax'] as num).toDouble();
                }
                totals[taxID] = (totals[taxID] ?? 0.0) + amount;
              }
            }
          }
        }
        else{
          print("not taxes list");
        }
      } catch (e) {
        //print("json parsing error$e");
      }
    }
    totals.updateAll((key, value) => double.parse(value.toStringAsFixed(2)));
    print(totals);
    return totals;
  }

   void showMonthlyTax() {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title:  const Text("Monthly Tax Calculations" , style: TextStyle(fontSize: 12),),
          content:SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min ,
              children: [
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    
                    children: [
                      const Text("Month" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("${monthlyTaxDetails['month']}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    
                    children: [
                      const Text("Receipt Count ZWG" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("${monthlyTaxDetails['receiptCount']}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    children: [
                      const Text("Total Tax Amount ZWG" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("\$${(monthlyTaxDetails['totalTaxAmount'] as double).toStringAsFixed(2)}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    children: [
                      const Text("Sales With Tax ZWG" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("\$${monthlyTaxDetails['totalSalesWithTax']}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15,),
                 Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    children: [
                      const Text("Receipt Count USD" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("${monthlyTaxDetailsUSD['receiptCount']}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    children: [
                      const Text("Total Tax Amount USD" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("\$${(monthlyTaxDetailsUSD['totalTaxAmount'] as double).toStringAsFixed(2)}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 43,
                  width: 300,
                  //child: Text("Total Tax Amount: ${monthlyTaxDetails['totalTaxAmount']}"),
                  child: Column(
                    children: [
                      const Text("Sales With Tax USD" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                      //const SizedBox(height: 10,),
                      Text("\$${monthlyTaxDetailsUSD['totalSalesWithTax']}", style: TextStyle(fontSize: 16  , fontWeight: FontWeight.bold , color: Colors.white),)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Icon(Icons.close , color: Colors.white,),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //   },
          //   child: const Text('Submit'),
          // ),
          ],
        );
      }
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return Future.value(false); // Prevents the back navigation
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("My Taxes" , style: TextStyle(fontSize: 14, color: Colors.white, fontWeight:  FontWeight.normal),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()),
            )),
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
      
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Lottie.asset(
                      'assets/taxAnimation.json'
                    ),
                  ),
                ),
      
                receiptsPending.isEmpty?
                Container(
                  width: 390,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Center(
                    child: Text("100% Tax Compliance!!😁" , style: TextStyle(fontSize: 18, color: Colors.white,fontWeight:  FontWeight.w500),),
                  ),
                ) :
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Center(
                    child: Text("Pending Receipts" , style: TextStyle(fontSize: 18, color: Colors.white,fontWeight:  FontWeight.w500),),
                  ),
                ),
                const SizedBox(height: 30,),
                const Text("Currency Selector" , style: TextStyle(fontSize: 16, color:  const Color.fromARGB(255, 14, 19, 29),fontWeight:  FontWeight.bold),),
                Container(
                  height: 70,
                  width: 390,
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
                      hint: Text("Select Currency"),
                      value: selectedCurrency,
                      onChanged: (value){
                        setState(() {
                          selectedCurrency = value;
                        });
                        loadTaxTotals();
                        getTotalTax();
                      },
                      items: currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                    ),
                  ),
                ),
               
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 120,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children:[
                          const SizedBox(height: 15,),
                          const Text("Total Tax Returns" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                          const SizedBox(height: 10,),
                          Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                              ),
                            ),
                          Text("$totalTaxAmount", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                        ] 
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,  
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children:[
                          const SizedBox(height: 15,),
                          const Text("15% Tax" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                          const SizedBox(height: 10,),
                           Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                              ),
                            ),
                          Text("$taxTotal3", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                        ] 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 120,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children:[
                          const SizedBox(height: 15,),
                          const Text("Zero Tax" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                          const SizedBox(height: 10,), 
                          Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                              ),
                            ),
                          Text("$taxTotal2", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                        ] 
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children:[
                          const SizedBox(height: 15,),
                          const Text("Tax Exempted" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                          const SizedBox(height: 10,),
                         Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                              ),
                            ),
                          Text("$taxTotal1", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                        ] 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:30,),
                const Text("Percentage Sales Per Tax Group" , style: TextStyle(fontSize: 16, color:  const Color.fromARGB(255, 14, 19, 29),fontWeight:  FontWeight.bold),),
                Container(
                  height: 300,
                  width: 390,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: tax1Percent,
                            color: Colors.deepPurpleAccent,
                            title: "$tax1Percent%",
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: tax2Percent,
                            color: Colors.green,
                            title: '$tax2Percent%',
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            radius: 50,
                          ),
                          PieChartSectionData(
                            value: tax3Percent,
                            color: Colors.blue,
                            title: '$tax3Percent%',
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            radius: 50,
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                      Text(" Tax Exempted" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                      const SizedBox(width: 15,),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                      Text(" Zero Tax" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                      const SizedBox(width: 15,),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                      Text(" 15 %" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                const Text("Products with top VAT returns" , style: TextStyle(fontSize: 16, color:  const Color.fromARGB(255, 14, 19, 29),fontWeight:  FontWeight.bold),),
                const SizedBox(height: 10,),
                Container(
                  height: 200,
                  width: 390,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10)
                  ),
                    child: ListView.builder(
                      itemCount: topProducts.length,
                      itemBuilder:(context, index){
                        final product = topProducts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0), 
                            color: Colors.white, 
                          ),
                          child: ListTile(
                            title: Text(product['productName']),
                            subtitle: Text("Quantity: ${product['totalQuantity']}"),
                            trailing: Text("\$${product['totalSales']}"),
                          ),
                        );
                      } ,
                    ),
                ),
                const SizedBox(height: 20,),
                // CustomOutlineBtn(
                //     height: 50,
                //     text: "View Quarterly Tax",
                //     color: Colors.blue ,
                //     color2: Colors.blue,
                //     onTap: (){
                //       Get.to(()=> SalesReportPage());
                //     },
                // ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                    height: 50,
                    text: "View Month's Tax",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      showMonthlyTax();
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

