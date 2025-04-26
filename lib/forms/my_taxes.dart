import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
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
  double taxTotal1 = 0.0;
  double taxTotal2 = 0.0;
  double taxTotal3 = 0.0;

  @override
  void initState() {
    super.initState();
    getTotalTax();
    loadTaxTotals();
  }

  void loadTaxTotals() async{
    Map<String, double> totals = await getTaxTotalsByID();
    setState(() {
      taxTotal1 = totals["1"] ?? 0.0;
      taxTotal2 = totals["2"] ?? 0.0;
      taxTotal3 = totals["3"] ?? 0.0;
    });
  }
  
  getTotalTax() async{
    final List<Map<String, dynamic>> result = await dbHepler.getTotalTaxAmount();
    if(result.isNotEmpty && result.first['totalTaxAmount'] != null){
      setState(() {
        double rtotalTaxAmount = result.first['totalTaxAmount'];
        totalTaxAmount =  double.parse(rtotalTaxAmount.toStringAsFixed(2));
        //totalTaxAmount.round();
      });
    }
  }

  Future<Map<String, double>>  getTaxTotalsByID() async{
    final receipts = await dbHepler.getAllFiscalInvoice();
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
          print(taxes);
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
        print("json parsing error$e");
      }
    }
    totals.updateAll((key, value) => double.parse(value.toStringAsFixed(2)));
    print(totals);
    return totals;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("My Taxes" , style: TextStyle(fontSize: 14, color: Colors.white, fontWeight:  FontWeight.normal),),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 14, 19, 29),
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
              const SizedBox(height: 15,),
              Center(
                child: Image.asset(
                    'assets/accounting.png',
                    height: 100,
                  ),
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 120,
                    width: 190,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children:[
                        const SizedBox(height: 15,),
                        const Text("Total Tax Returns" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                        const SizedBox(height: 10,),
                        Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(Icons.monetization_on_rounded , color: Colors.green, size: 30,),
                            ),
                          ),
                        Text("$totalTaxAmount", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.green),)
                      ] 
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 190,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children:[
                        const SizedBox(height: 15,),
                        const Text("15% Tax" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                        const SizedBox(height: 10,),
                         Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(Icons.monetization_on_rounded , color: Colors.green, size: 30,),
                            ),
                          ),
                        Text("$taxTotal3", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.green),)
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
                    width: 190,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children:[
                        const SizedBox(height: 15,),
                        const Text("Zero Tax" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                        const SizedBox(height: 10,), 
                        Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(Icons.monetization_on_rounded , color: Colors.green, size: 30,),
                            ),
                          ),
                        Text("$taxTotal2", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.green),)
                      ] 
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 190,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 19, 29),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children:[
                        const SizedBox(height: 15,),
                        const Text("Tax Exempted" , style: TextStyle(fontSize: 14, color: Colors.white,fontWeight:  FontWeight.w500),),
                        const SizedBox(height: 10,),
                       Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Icon(Icons.monetization_on_rounded , color: Colors.green, size: 30,),
                            ),
                          ),
                        Text("$taxTotal1", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.green),)
                      ] 
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Quarterly Tax Returns" , style: TextStyle(fontSize: 16, color:  const Color.fromARGB(255, 14, 19, 29),fontWeight:  FontWeight.bold),),
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
                          value: 50,
                          color: Colors.deepPurpleAccent,
                          title: "50%",
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: 20,
                          color: Colors.green,
                          title: '30%',
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: 10,
                          color: Colors.blue,
                          title: '20%',
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
              CustomOutlineBtn(
                  height: 50,
                  text: "View Quarterly Tax",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=> SalesReportPage());
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  
}