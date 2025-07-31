import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';

class Fiscalizedcustomers extends StatefulWidget {
  const Fiscalizedcustomers({super.key});

  @override
  State<Fiscalizedcustomers> createState() => _FiscalizedcustomersState();
}

class _FiscalizedcustomersState extends State<Fiscalizedcustomers> {

  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> customersData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllFiscalCustomers();
    setState(() {
      customersData = data;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("Fiscalized Customers List" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Get.back();
              },
            ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: 10,),  
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          headingRowColor: MaterialStateProperty.all(Colors.blue),
                          columns: const [
                            DataColumn(label: Text('Customer ID')),
                            DataColumn(label: Text('TradeName')),
                            DataColumn(label: Text('TIN')),
                            DataColumn(label: Text('VAT')),
                            DataColumn(label: Text('Address')),
                            DataColumn(label: Text('Email')),
                          ],
                          rows: customersData
                              .map(
                                (customer) => DataRow(
                                  cells: [
                                    DataCell(Text(customer['customerID'].toString())),
                                    DataCell(Text(customer['tradeName'].toString())),
                                    DataCell(Text(customer['tinNumber'].toString())),
                                    DataCell(Text(customer['vatNumber'].toString())),
                                    DataCell(Text(customer['address'].toString())),
                                    DataCell(Text(customer['email'].toString())),
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
          ),
    );
  }
}