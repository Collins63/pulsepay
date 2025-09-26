import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/custom_button.dart';

class SubmittedReceiptsTable extends StatefulWidget {
  const SubmittedReceiptsTable({super.key});
  @override
  State<SubmittedReceiptsTable> createState() => _submittedReceiptsTableState();
}

class _submittedReceiptsTableState extends State<SubmittedReceiptsTable> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> submittedReceipts= [];
  List<int> selectedReceipt = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmittedReceipts();
  }

  Future<void> fetchSubmittedReceipts() async {
    List<Map<String, dynamic>> data = await dbHelper.getSubmittedReceipts();
    setState(() {
      submittedReceipts = data;
      isLoading = false;
    });
  }

  void toggleSelection(int receiptGlobalNo) {
    setState(() {
      if (selectedReceipt.contains(receiptGlobalNo)) {
        selectedReceipt.remove(receiptGlobalNo);
      } else {
        selectedReceipt.add(receiptGlobalNo);
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        centerTitle: true,
        title: const Text(
          "Submitted Receipts",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getSubmittedReceipts(), // async fetch
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No receipts found"));
        }

        final submittedReceipts = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  headingRowColor: MaterialStateProperty.all(Colors.blue),
                  columns: const [
                    DataColumn(label: Text('Select')),
                    DataColumn(label: Text('ReceiptGlobalNo')),
                    DataColumn(label: Text('ReceiptCounter')),
                    DataColumn(label: Text('FiscalDayNo')),
                    DataColumn(label: Text('InvoiceNo')),
                    DataColumn(label: Text('ReceiptID')),
                    DataColumn(label: Text('ReceiptType')),
                    DataColumn(label: Text('ReceiptCurrency')),
                    DataColumn(label: Text('MoneyType')),
                    DataColumn(label: Text('ReceiptDate')),
                    DataColumn(label: Text('ReceiptTime')),
                    DataColumn(label: Text('ReceiptTotal')),
                    DataColumn(label: Text('TaxCode')),
                    DataColumn(label: Text('taxPercent')),
                    DataColumn(label: Text('taxAmount')),
                    DataColumn(label: Text('salesAmountwithTax')),
                    DataColumn(label: Text('receiptHash')),
                    DataColumn(label: Text('receiptJsonbody')),
                    DataColumn(label: Text('statustoFdms')),
                    DataColumn(label: Text('qrurl')),
                    DataColumn(label: Text('receiptServerSignature')),
                    DataColumn(label: Text('submitReceiptServerresponseJson')),
                    DataColumn(label: Text('total15Vat')),
                    DataColumn(label: Text('totalNonVat')),
                    DataColumn(label: Text('totalExempt')),
                    DataColumn(label: Text('totalWT')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: submittedReceipts.map((receipt) {
                    final receiptID = receipt['receiptGlobalNo'];
                    double taxAmount = receipt['taxAmount'];
                    return DataRow(
                      cells: [
                        DataCell(
                          Checkbox(
                            value: selectedReceipt.contains(receiptID),
                            onChanged: (_) => toggleSelection(receiptID),
                          ),
                        ),
                        DataCell(Text(receipt['receiptGlobalNo'].toString())),
                        DataCell(Text(receipt['receiptCounter'].toString())),
                        DataCell(Text(receipt['FiscalDayNo'].toString())),
                        DataCell(Text(receipt['InvoiceNo'].toString())),
                        DataCell(Text(receipt['receiptID'].toString())),
                        DataCell(Text(receipt['receiptType'].toString())),
                        DataCell(Text(receipt['receiptCurrency'].toString())),
                        DataCell(Text(receipt['moneyType'].toString())),
                        DataCell(Text(receipt['receiptDate'].toString())),
                        DataCell(Text(receipt['receiptTime'].toString())),
                        DataCell(Text(receipt['receiptTotal'].toString())),
                        DataCell(Text(receipt['taxCode'].toString())),
                        DataCell(Text(receipt['taxPercent'].toString())),
                        DataCell(Text(taxAmount.toStringAsFixed(2))),
                        DataCell(Text(receipt['SalesAmountwithTax'].toString())),
                        DataCell(Text(receipt['receiptHash'].toString())),
                        DataCell(Text(receipt['receiptJsonbody'].toString())),
                        DataCell(Text(receipt['StatustoFDMS'].toString())),
                        DataCell(Text(receipt['qrurl'].toString())),
                        DataCell(Text(receipt['receiptServerSignature'].toString())),
                        DataCell(Text(
                            receipt['submitReceiptServerresponseJSON'].toString())),
                        DataCell(Text(receipt['Total15VAT'].toString())),
                        DataCell(Text(receipt['TotalNonVAT'].toString())),
                        DataCell(Text(receipt['TotalExempt'].toString())),
                        DataCell(Text(receipt['TotalWT'].toString())),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  int receiptGlobalNumber =
                                      receipt['receiptGlobalNo'];
                                  TextEditingController receiptController =
                                      TextEditingController();
                                  receiptController.text =
                                      receipt['receiptJsonbody'];
                                  final formKey = GlobalKey<FormState>();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Edit Receipt"),
                                        content: Form(
                                          key: formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text("Receipt",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              TextFormField(
                                                controller: receiptController,
                                                decoration: InputDecoration(
                                                  labelText: 'Product Name',
                                                  labelStyle: TextStyle(
                                                      color: Colors
                                                          .grey.shade600),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Product name is required";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              String receipt =
                                                  receiptController.text;
                                              try {
                                                await dbHelper.updateReceipt(
                                                    receiptGlobalNumber,
                                                    receipt);
                                                Get.snackbar("Success",
                                                    "Receipt updated",
                                                    backgroundColor:
                                                        Colors.green,
                                                    colorText: Colors.white,
                                                    snackPosition:
                                                        SnackPosition.TOP);
                                                Navigator.of(context).pop();
                                              } catch (e) {
                                                Get.snackbar("Error Updating",
                                                    "$e",
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text("Update"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 50),
              if (selectedReceipt.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomOutlineBtn(
                      width: 150,
                      height: 50,
                      text: "View Day Sales",
                      color: const Color.fromARGB(255, 14, 19, 29),
                      color2: const Color.fromARGB(255, 14, 19, 29),
                      onTap: () {},
                    ),
                    CustomOutlineBtn(
                      width: 150,
                      height: 50,
                      text: "Day Details",
                      color: const Color.fromARGB(255, 14, 19, 29),
                      color2: const Color.fromARGB(255, 14, 19, 29),
                      onTap: () {},
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    ),
  );
}


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: PreferredSize(
  //       preferredSize: Size.fromHeight(50)
  //       ,child: AppBar(
  //         centerTitle: true,
  //         title: const Text("Submitted Receipts" , style: TextStyle(fontSize: 20, color: Colors.white, fontWeight:  FontWeight.bold),),
  //         iconTheme: const IconThemeData(color: Colors.white),
  //         backgroundColor: Colors.blue,
  //         shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.only(
  //                 bottomLeft: Radius.circular(25),
  //                 bottomRight: Radius.circular(25)
  //               )
  //             ),
  //       )
  //     ),
  //     body: isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : SingleChildScrollView(
  //           scrollDirection: Axis.vertical,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const SizedBox(height: 20,),
  //               SingleChildScrollView(
  //                   scrollDirection: Axis.horizontal,
  //                   child: SingleChildScrollView(
  //                     child: DataTable(
  //                       headingTextStyle: const TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                       headingRowColor: MaterialStateProperty.all(Colors.blue),
  //                       columns: const [
  //                         DataColumn(label: Text('Select')),
  //                         DataColumn(label: Text('ReceiptGlobalNo')),
  //                         DataColumn(label: Text('ReceiptCounter')),
  //                         DataColumn(label: Text('FiscalDayNo')),
  //                         DataColumn(label: Text('InvoiceNo')),
  //                         DataColumn(label: Text('ReceiptID')),
  //                         DataColumn(label: Text('ReceiptType')),
  //                         DataColumn(label: Text('ReceiptCurrency')),
  //                         DataColumn(label: Text('MoneyType')),
  //                         DataColumn(label: Text('ReceiptDate')),
  //                         DataColumn(label: Text('ReceiptTime')),
  //                         DataColumn(label: Text('ReceiptTotal')),
  //                         DataColumn(label: Text('TaxCode')),
  //                         DataColumn(label: Text('taxPercent')),
  //                         DataColumn(label:Text('taxAmount')),
  //                         DataColumn(label:Text('salesAmountwithTax')),
  //                         DataColumn(label:Text('receiptHash')),
  //                         DataColumn(label:Text('receiptJsonbody')),
  //                         DataColumn(label:Text('statustoFdms')),
  //                         DataColumn(label:Text('qrurl')),
  //                         DataColumn(label:Text('receiptServerSignature')),
  //                         DataColumn(label:Text('submitReceiptServerresponseJson')),
  //                         DataColumn(label:Text('total15Vat')),
  //                         DataColumn(label:Text('totalNonVat')),
  //                         DataColumn(label:Text('totalExempt')),
  //                         DataColumn(label:Text('totalWT')),
  //                         DataColumn(label: Text('Actions'))
  //                       ],
  //                       rows: submittedReceipts
  //                           .map(
  //                             (receipt) {
  //                               final receiptID = receipt['receiptGlobalNo'];
  //                               return DataRow(
  //                               cells: [
  //                                 DataCell(
  //                                   Checkbox(
  //                                     value: selectedReceipt.contains(receiptID),
  //                                     onChanged: (_) => toggleSelection(receiptID),
  //                                   ),
  //                                 ),
  //                                 DataCell(Text(receipt['receiptGlobalNo'].toString())),
  //                                 DataCell(Text(receipt['receiptCounter'].toString())),
  //                                 DataCell(Text(receipt['FiscalDayNo'].toString())),
  //                                 DataCell(Text(receipt['InvoiceNo'].toString())),
  //                                 DataCell(Text(receipt['receiptID'].toString())),
  //                                 DataCell(Text(receipt['receiptType'].toString())),
  //                                 DataCell(Text(receipt['receiptCurrency'].toString())),
  //                                 DataCell(Text(receipt['moneyType'].toString())),
  //                                 DataCell(Text(receipt['receiptDate'].toString())),
  //                                 DataCell(Text(receipt['receiptTime'].toString())),
  //                                 DataCell(Text(receipt['receiptTotal'].toString())),
  //                                 DataCell(Text(receipt['taxCode'].toString())),
  //                                 DataCell(Text(receipt['taxPercent'].toString())),
  //                                 DataCell(Text(receipt['taxAmount'].toString())),
  //                                 DataCell(Text(receipt['SalesAmountwithTax'].toString())),
  //                                 DataCell(Text(receipt['receiptHash'].toString())),
  //                                 DataCell(Text(receipt['receiptJsonbody'].toString())),
  //                                 DataCell(Text(receipt['StatustoFDMS'].toString())),
  //                                 DataCell(Text(receipt['qrurl'].toString())),
  //                                 DataCell(Text(receipt['receiptServerSignature'].toString())),
  //                                 DataCell(Text(receipt['submitReceiptServerresponseJSON'].toString())),
  //                                 DataCell(Text(receipt['Total15VAT'].toString())),
  //                                 DataCell(Text(receipt['TotalNonVAT'].toString())),
  //                                 DataCell(Text(receipt['TotalExempt'].toString())),
  //                                 DataCell(Text(receipt['TotalWT'].toString())),
  //                                 DataCell(
  //                                   Row(children: [
  //                                     IconButton(
  //                                       onPressed: (){
  //                                         int receiptGlobalNumber = receipt['receiptGlobalNo'];
  //                                         TextEditingController receiptController = TextEditingController();
  //                                         receiptController.text = receipt['receiptJsonbody'];
  //                                         final formKey = GlobalKey<FormState>();
  //                                         showDialog(
  //                                           context: context,
  //                                           barrierDismissible: false,
  //                                           builder: (BuildContext context){
  //                                             return AlertDialog(
  //                                               title: const Text("Edit Receipt"),
  //                                               content: Form(
  //                                                 key: formKey,
  //                                                 child: Column(
  //                                                   mainAxisSize: MainAxisSize.min,
  //                                                   children: [
  //                                                     Text("Receipt", style: TextStyle(fontSize: 12),),
  //                                                     TextFormField(
  //                                                       controller: receiptController,
  //                                                       decoration: InputDecoration(
  //                                                           labelText: 'Product Name',
  //                                                           labelStyle: TextStyle(color:Colors.grey.shade600 ),
  //                                                           filled: true,
  //                                                           fillColor: Colors.white,
  //                                                           border:const OutlineInputBorder()
  //                                                       ),
  //                                                       style: const TextStyle(color: Colors.black),
  //                                                       validator: (value){
  //                                                         if(value!.isEmpty){
  //                                                           return "Product name is required";
  //                                                         }return null;
  //                                                       },
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               ),
  //                                               actions: [
  //                                                 TextButton(
  //                                                   onPressed: (){
  //                                                     Navigator.of(context).pop();
  //                                                   },
  //                                                   child: const Text("Cancel")
  //                                                 ),
  //                                                 ElevatedButton(
  //                                                   onPressed: ()async {
  //                                                     String receipt = receiptController.text;
  //                                                     try {
  //                                                       await dbHelper.updateReceipt(receiptGlobalNumber, receipt);
  //                                                       Get.snackbar("Success","Receipt updated",
  //                                                         backgroundColor: Colors.green,
  //                                                         colorText: Colors.white,
  //                                                         snackPosition: SnackPosition.TOP
  //                                                       );
  //                                                        Navigator.of(context).pop();
  //                                                     } catch (e) {
  //                                                       Get.snackbar(
  //                                                         "Error Updating", "$e",
  //                                                         snackPosition: SnackPosition.TOP,
  //                                                         backgroundColor: Colors.red,
  //                                                         colorText: Colors.white
  //                                                       );
  //                                                        Navigator.of(context).pop();
  //                                                     }

  //                                                   },
  //                                                   child: const Text("Update")
  //                                                 )
  //                                               ],
  //                                             );
  //                                           }
  //                                         );
  //                                       },
  //                                       icon: const Icon(Icons.edit, color: Colors.blue,)
  //                                     )
  //                                   ],)
  //                                 )
  //                               ],
  //                             );
  //                           })
  //                           .toList(),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 50,),
  //                 if (selectedReceipt.isNotEmpty)
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   CustomOutlineBtn(
  //                     width: 150,
  //                     height: 50,
  //                     text: "View Day Sales",
  //                     color:const Color.fromARGB(255, 14, 19, 29),
  //                     color2: const Color.fromARGB(255, 14, 19, 29),
  //                     onTap: (){
  //                       //final i = selectedUsers.first;
  //                       //fetchSalesForInvoice(invoiceId);
  //                     },
  //                   ),
                    
  //                   CustomOutlineBtn(
  //                     width: 150,
  //                     height: 50,
  //                     text: "Day Details",
  //                     color:const Color.fromARGB(255, 14, 19, 29),
  //                     color2: const Color.fromARGB(255, 14, 19, 29),
  //                     onTap: (){
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //   );
  // }
}
