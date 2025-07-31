import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pulsepay/SQLite/database_helper.dart';

class Customerpurchases extends StatefulWidget {
  const Customerpurchases({super.key});
  @override
  State<Customerpurchases> createState() => _customerPurchasesPageState();
}

class _customerPurchasesPageState extends State<Customerpurchases> {
  String selectedPeriod = "Daily"; // Default selection
  List<Map<String, dynamic>> salesData = [];
  bool isLoading = true;
  double totalSales = 0.0;
  DatabaseHelper db = DatabaseHelper();
  String? selectedUser;
  List<String> users = [];
  Map<String, dynamic>? selectedCustomer;
  List<Map<String, dynamic>> customers =[];
  int? selectedCustomerId;

  Future<void> fetchCustomers() async {
    List<Map<String, dynamic>> data = await db.getAllCustomers();
    setState(() {
      customers = data;
      isLoading = false;
    });
  }

  Future<List<String>> fetchUsers() async{
    final List<Map<String, dynamic>> users = await db.getAllUsers();
    return users.map((row) => row['userName'] as String).toList();
  }

  Future<void> loadUsers()async{
    final results = await fetchUsers();
    setState(() {
      users = results;
    });
  }

  
  @override
  void initState() {
    super.initState();
    loadUsers();
    fetchCustomers();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("Customer Purchases" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
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
      body: 
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
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
                    child: DropdownButton<int>(
                      value: selectedCustomerId,
                      onChanged: (int? newId) async {
                        try {
                          setState(() {
                            selectedCustomerId = newId;
                          });
                          // Find the selected customer map
                          final selectedCustomer = customers.firstWhere(
                            (cust) => cust['customerID'] == newId,
                          );
                            salesData = await db.getSalesByCustomer(selectedCustomer['customerID']);

                        } catch (e) {
                          Get.snackbar(
                            "Error loading data",
                            "$e",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white
                          );
                        }
                      },
                      hint: Text("Select a Customer"),
                      items: customers.map<DropdownMenuItem<int>>((customer) {
                        return DropdownMenuItem<int>(
                          value: customer['customerID'],
                          child: Text(customer['tradeName'] ?? 'Unknown'),
                        );
                      }).toList(),
                    )
                  ),
                ),
                const SizedBox(height: 20,),
                isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Sale ID')),
                          DataColumn(label: Text('Invoice Id')),
                          DataColumn(label: Text('Product Id')),
                          DataColumn(label: Text('Currency')),
                          DataColumn(label: Text('Total Amount')),
                          DataColumn(label: Text('Tax')),
                          DataColumn(label: Text('Rate'))
                        ],
                        rows: salesData
                            .map(
                              (sale) => DataRow(
                                cells: [
                                  DataCell(Text(sale['saleId'].toString())),
                                  DataCell(Text(sale['invoiceId'].toString())),
                                  DataCell(Text(sale['productId'].toString())),
                                  DataCell(Text(sale['currency'].toString())),
                                  DataCell(Text(sale['sellingPrice'].toString())),
                                  DataCell(Text(sale['tax'].toString())),
                                  DataCell(Text(sale['rate'].toString()))
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}

