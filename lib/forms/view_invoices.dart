
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/find_invoiceField.dart';
import 'package:pulsepay/main.dart';

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
  String? receiptDeviceSignature_signature_hex ;
  String? first16Chars;
  String? receiptDeviceSignature_signature;
  String genericzimraqrurl = "https://fdmstest.zimra.co.zw/";
  int deviceID = 22662;
  String? generatedJson;
  String? fiscalResponse;
  String? creditReason;

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
    creditReason = enteredReason;
    generateCreditFiscalJSON();
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



String createCreditNote(String receiptJsonString,
{
  required String fiscalDay ,
  required String newReceiptGlobalNo,
  required int newReceiptCounter,
  required String newReceiptDate,
  required String receiptID,
  required String newSignature,
  required String newHash,
}) {
  // Parse the original receipt
  final Map<String, dynamic> original = json.decode(receiptJsonString);
  final Map<String, dynamic> receipt = original["receipt"];

  // Clone the receipt to a new object
  final Map<String, dynamic> creditNoteBody = Map.from(receipt);

  // 1. Negate receiptTaxes values
  List<dynamic> originalTaxes = creditNoteBody["receiptTaxes"];
  creditNoteBody["receiptTaxes"] = originalTaxes.map((tax) {
    return {
      ...tax,
      "salesAmountWithTax": -1 * tax["salesAmountWithTax"],
      "taxAmount": tax["taxAmount"] != "0" && tax["taxAmount"] !="0.00" ? (-1 * double.parse(tax["taxAmount"])).toStringAsFixed(2) : tax["taxAmount"].toString(),
    };
  }).toList();

  //negate receipt payments
  List<dynamic> originalPayments = creditNoteBody["receiptPayments"];
  creditNoteBody["receiptPayments"] = originalPayments.map((payment) {
    return {
      ...payment,
      "paymentAmount":
          (-1 * double.parse(payment["paymentAmount"])).toStringAsFixed(2),
    };
  }).toList();
  // 2. Negate receiptLines totals
  List<dynamic> originalLines = creditNoteBody["receiptLines"];
  creditNoteBody["receiptLines"] = originalLines.map((line) {
    return {
      ...line,
      "receiptLineTotal":
          (-1 * double.parse(line["receiptLineTotal"])).toStringAsFixed(2),
    };
  }).toList();

  // 3. Negate receiptTotal
  creditNoteBody["receiptTotal"] =
      (-1 * double.parse(creditNoteBody["receiptTotal"])).toStringAsFixed(2);

  // Update receiptGlobalNo, receiptCounter, receiptDate, and add receiptNotes
  creditNoteBody["receiptGlobalNo"] = int.parse(newReceiptGlobalNo);
  creditNoteBody["receiptCounter"] = newReceiptCounter;
  creditNoteBody["receiptDate"] = newReceiptDate ;
  creditNoteBody["receiptNotes"] = creditReason ?? "Credit Note";
  creditNoteBody["receiptType"] = "CREDITNOTE";
  creditNoteBody["receiptDeviceSignature"]={
    "signature" : newSignature,
    "hash" : newHash
  };

  // 4. Wrap in creditDebitNote and add required fields
  Map<String, dynamic> creditNote = {
    "receipt":{
    "creditDebitNote": {
      "receiptGlobalNo": receipt["receiptGlobalNo"].toString(),
      "fiscalDayNo": fiscalDay, // You can change this
      "receiptID": receiptID, // You can generate or pass this
      "deviceID": deviceID.toString(), // Set your device ID here
    },
    ...creditNoteBody,
    }
  };

  // 5. Convert to JSON string
  return json.encode(creditNote);
}


Future<void> generateCreditFiscalJSON() async{
  final int invoiceId = selectedInvoices.first;
  try {
    print("Entered generate credit FiscalJSON");

    String filePath = "/storage/emulated/0/Pulse/Configurations/mindTest_T_certificate.p12";
    String password = "mindTest123";


    int fiscalDayNo = await dbHelper.getlatestFiscalDay();
    int nextReceiptCounter = await dbHelper.getNextReceiptCounter(fiscalDayNo);
    int nextInvoice = await dbHelper.getNextInvoiceId();
    int getReceiptGlobalNo = await dbHelper.getLatestReceiptGlobalNo();
    int nextReceiptGlobalNo = getReceiptGlobalNo + 1;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);

    List<Map<String, dynamic>> getSubmittedReceipt =  await dbHelper.getReceiptSubmittedById(invoiceId);
    int deviceId = 22662;
    String receiptJsonbody = getSubmittedReceipt[0]['receiptJsonbody'].toString();
    String receiptID = getSubmittedReceipt[0]['receiptID'].toString();
    String receiptFiscDayNo = getSubmittedReceipt[0]['FiscalDayNo'].toString();
    Map<String, dynamic> jsonMap = jsonDecode(receiptJsonbody);
    Map<String, dynamic> receipt = jsonMap["receipt"];
    print(receipt);
    String receiptType = "CREDITNOTE";
    final String invoiceNumber = receipt['invoiceNo'].toString();
    final String receiptDate = receipt['receiptDate'].toString();
    String currency = receipt['receiptCurrency'].toString();
    String totalAmount = receipt['receiptTotal'].toString();
    double totalAmountDouble = double.parse(totalAmount);
    int totalAmountInCents = (totalAmountDouble * 100 *-1).round();
    //22662FISCALINVOICEUSD572025-04-18T12:57:41600B0.000200C15.00524006VTloJCYlWhu4kvKaGCnRkhP9CIlW66+W3QhQAnhkeI=
    String taxesConcat = "";
    String previousReceiptHash = await dbHelper.getLatestReceiptHash();
    List<dynamic> taxes = receipt['receiptTaxes'];
    print("taxes concat");
    for(var tax in taxes){
      String taxcode = tax['taxCode'].toString();
      String taxPercent = tax['taxPercent'].toString();
      //String taxId = tax['taxId'].toString();
      //double taxAmount = double.parse(tax['taxAmount']);
      double taxAmount = tax['taxAmount'] is String
        ? double.parse(tax['taxAmount'])
        : tax['taxAmount'].toDouble();
      
      int taxAmountInCents = (taxAmount * 100 *-1).round();
      //double SalesAmountwithTax = double.parse(tax['salesAmountWithTax']);
      double SalesAmountwithTax = tax['salesAmountWithTax'] is String
        ? double.parse(tax['salesAmountWithTax'])
        : tax['salesAmountWithTax'].toDouble();
      int salesAmountInCents = (SalesAmountwithTax * 100 *-1).round();
      taxesConcat += "$taxcode$taxPercent$taxAmountInCents$salesAmountInCents";
    }
    print(" after taxes concat");
    String finalString = "$deviceId$receiptType$currency$nextReceiptGlobalNo$formattedDate$totalAmountInCents$taxesConcat$previousReceiptHash";
    //CODE BELOW TO FOLLOW AFTER RECEIPT SUBMITTI
    // Update the invoice status in the database (add your implementation here)f
    finalString.trim();
    var bytes = utf8.encode(finalString);
    var digest = sha256.convert(bytes);
    final hash = base64.encode(digest.bytes);

    print(finalString);
    print("Hash  : $hash");
    //create creditnote json body

    //ensure that signing does not fail
    try {
      //String data = await useRawString();
      //List<String>? signature = await getSignatureSignature(data);
      //receiptDeviceSignature_signature_hex = signature?[0];
      //receiptDeviceSignature_signature  = signature?[1];
      final Map<String, String> signedDataMap  = await signData(filePath, password, finalString);
      //final Map<String, dynamic> signedDataMap = jsonDecode(signedDataString);
      receiptDeviceSignature_signature_hex = signedDataMap["receiptDeviceSignature_signature_hex"] ?? "";
      receiptDeviceSignature_signature = signedDataMap["receiptDeviceSignature_signature"] ?? "";
      first16Chars = signedDataMap["receiptDeviceSignature_signature_md5_first16"] ?? "";
    } catch (e) {
      Get.snackbar("Signing Error", "$e", snackPosition: SnackPosition.TOP);
      
    }
    print("Signed Data: $receiptDeviceSignature_signature");
    String creditNoteJson = createCreditNote(receiptJsonbody,newHash: hash , newSignature: receiptDeviceSignature_signature.toString()  , fiscalDay: receiptFiscDayNo ,newReceiptGlobalNo: nextReceiptGlobalNo.toString(), newReceiptCounter: nextReceiptCounter, newReceiptDate: formattedDate , receiptID: receiptID);
    if (creditNoteJson.isNotEmpty) {
      cancelSelectedInvoice();
    }
    File file = File("/storage/emulated/0/Pulse/Configurations/jsonFile.txt");
    await file.writeAsString(creditNoteJson);
    print(creditNoteJson);

  } catch (e) {
    print("tryyyy  Error: $e");
    Get.snackbar("Try Error", "$e",
    snackPosition: SnackPosition.TOP);
  }
}

void cancelSelectedInvoice() async {
  // Assume selectedInvoices contains the invoice ID(s) to cancel

  if (selectedInvoices.isNotEmpty) {
    final int invoiceId = selectedInvoices.first;
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