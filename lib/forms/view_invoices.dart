import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/custom_field.dart';
import 'package:pulsepay/common/find_invoiceField.dart';

class ViewInvoices extends StatefulWidget {
  const ViewInvoices({super.key});

  @override
  State<ViewInvoices> createState() => _ViewInvoicesState();
}

class _ViewInvoicesState extends State<ViewInvoices> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String,dynamic>> invoiceResults = [];
  List<int> selectedInvoices = [];
  bool isLoading = false;


  void showViewInvoice(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sale Summary"),
                              content: ListView.builder(
                                itemCount: invoiceResults.length,
                                itemBuilder: (context , index){
                                final product = invoiceResults[index];
                                return 
                                  ListTile(
                                    title: Text(product['productName'].toString()),
                                    subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toString()}"),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 14, 19, 29),
                                        borderRadius: BorderRadius.circular(50.0)
                                      ),
                                      child:  Center(
                                        child:  Text(
                                          product['quantity'].toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                        ),
                                      ),

                                    ),
                                  )
                                ;
                              }                                
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
  }

  void showPasswordPrompt() {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title:  const Text("Enter Password"),
          content:Column(
            mainAxisSize: MainAxisSize.min ,
            children: [
              const Text("Please enter admin password and reason to cancel the invoice"),
              const SizedBox(height: 10,),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: reasonController,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredPassword = passwordController.text.trim();
              final eneteredReason = reasonController.text;
              validatePassword(enteredPassword , eneteredReason);
            },
            child: const Text('Submit'),
          ),
          ],
        );
      }
    );
  }

  void validatePassword(String enteredPassword , String enteredReason) async {
  const String correctPassword = 'admin123'; // Replace with your password logic

  if (enteredPassword == correctPassword && enteredReason != "") {
    // Password is correct, proceed to cancel the invoice
    cancelSelectedInvoice();
    Navigator.of(context).pop(); // Close the dialog
    
  } else {
    Navigator.of(context).pop();
    Get.snackbar(
      'Denied!',
      'Wrong password/Reason not found',
      icon: const Icon(Icons.error, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP,
    );
  }
}

void cancelSelectedInvoice() {
  // Assume selectedInvoices contains the invoice ID(s) to cancel
  if (selectedInvoices.isNotEmpty) {
    final int invoiceId = selectedInvoices.first;

    // Update the invoice status in the database (add your implementation here)
    dbHelper.cancelInvoice(invoiceId);
    setState(() {
      //searchResults.removeWhere((invoice) => invoice['invoiceId'] == invoiceId);
      searchResults = List<Map<String, dynamic>>.from(searchResults);
      searchResults.removeWhere((invoice) => invoice['invoiceId'] == invoiceId);
      selectedInvoices.remove(invoiceId);
    });

    Get.snackbar(
      'Success',
      'Invoice has been cancelled',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
    );

  }
}



  Future<void> searchInvoices() async {
    final invoiceNumber = searchController.text.trim();
    if (invoiceNumber.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> results =
        await dbHelper.searchInvoicesByNumber(invoiceNumber);

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void toggleSelection(int invoiceId) {
    setState(() {
      if (selectedInvoices.contains(invoiceId)) {
        selectedInvoices.remove(invoiceId);
      } else {
        selectedInvoices.add(invoiceId);
      }
    });
  }

  void fetchSalesForInvoice(int invoiceId) async {
  final sales = await dbHelper.getSalesByInvoice(invoiceId);

  if (sales.isNotEmpty) {
    setState(() {
      invoiceResults = sales; // Update your UI with the fetched sales
    });
    showViewInvoice();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No sales found for invoice #$invoiceId'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title:  ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.arrow_left_circle,
                      size: 30,
                    ),
                  ),
              ),
              FindInvoicefield(
                controller: searchController,
              ),
              GestureDetector(
                onTap: (){
                  searchInvoices();
                },
                child: const Icon(
                  CupertinoIcons.search_circle,
                  size: 30,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (searchResults.isEmpty)
              const Center(child: Text('No invoices found.'))
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Select')),
                        DataColumn(label: Text('Invoice ID')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Total Items')),
                        DataColumn(label: Text('Total Price')),
                      ],
                      rows: searchResults.map((invoice) {
                        final invoiceId = invoice['invoiceId'];
                        return DataRow(
                          cells: [
                            DataCell(
                              Checkbox(
                                value: selectedInvoices.contains(invoiceId),
                                onChanged: (_) => toggleSelection(invoiceId),
                              ),
                            ),
                            DataCell(Text(invoice['invoiceId'].toString())),
                            DataCell(Text(invoice['date'].toString())),
                            DataCell(Text(invoice['totalItems'].toString())),
                            DataCell(Text(invoice['totalPrice'].toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            if (selectedInvoices.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomOutlineBtn(
                    width: 90,
                    height: 50,
                    text: "View",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29),
                    onTap: (){
                      final invoiceId = selectedInvoices.first;
                      fetchSalesForInvoice(invoiceId);
                    },
                  ),
                  CustomOutlineBtn(
                    width: 90,
                    height: 50,
                    text: "Cancel",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29) ,
                    onTap: (){
                      showPasswordPrompt();
                    },
                  ),
                  CustomOutlineBtn(
                    width: 90,
                    height: 50,
                    text: "Edit",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29),
                    onTap: (){
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}