import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';

class EditStockPurchases extends StatefulWidget {
  const EditStockPurchases({super.key});
  @override
  State<EditStockPurchases> createState() => _editStockPurchasesState();
}

class _editStockPurchasesState extends State<EditStockPurchases> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> purchases = [];
  List<int> selectedPurchase = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllStockPurchases();
    setState(() {
      purchases = data;
      isLoading = false;
    });
  }

  void toggleSelection(int purchaseId) {
    setState(() {
      if (selectedPurchase.contains(purchaseId)) {
        selectedPurchase.remove(purchaseId);
      } else {
        selectedPurchase.add(purchaseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      
                      columns: const [
                        DataColumn(label: Text("Select")),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Pay Method')),
                        DataColumn(label: Text("Supplier")),
                      ],
                      rows: purchases
                          .map(
                            (purchase) {
                              final purchaseId = purchase['purchaseId'];
                              return DataRow(
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: selectedPurchase.contains(purchaseId),
                                    onChanged: (_) => toggleSelection(purchaseId),
                                  ),
                                ),
                                DataCell(Text(purchase['date'].toString())),
                                DataCell(Text(purchase['productid'].toString())),
                                DataCell(Text(purchase['quantity'].toString())),
                                DataCell(Text(purchase['payMethod'].toString())),
                                DataCell(Text(purchase['supplier'].toString())),
                              ],
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                if (selectedPurchase.isNotEmpty)
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
                      //final i = selectedUsers.first;
                      //fetchSalesForInvoice(invoiceId);
                    },
                  ),
                  CustomOutlineBtn(
                    width: 90,
                    height: 50,
                    text: "Return Stock",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29) ,
                    onTap: (){
                      //showPasswordPrompt();
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

    );
  }
}
