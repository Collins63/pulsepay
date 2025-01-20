import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({super.key});
  @override
  State<ViewProducts> createState() => _viewProductsState();
}

class _viewProductsState extends State<ViewProducts> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> products = [];
  List<int> selectedProduct = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllProducts();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  void toggleSelection(int productId) {
    setState(() {
      if (selectedProduct.contains(productId)) {
        selectedProduct.remove(productId);
      } else {
        selectedProduct.add(productId);
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
                      columns: const [
                        DataColumn(label: Text("Select")),
                        DataColumn(label: Text('ProductName')),
                        DataColumn(label: Text('BarCode')),
                        DataColumn(label: Text('HS Code')),
                        DataColumn(label: Text('costPrice')),
                        DataColumn(label: Text("SellingPrice")),
                        DataColumn(label: Text('TAX')),
                        DataColumn(label: Text('Stock QTY')),
                      ],
                      rows: products
                          .map(
                            (product) {
                              final productId = product['productid'];
                              return DataRow(
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: selectedProduct.contains(productId),
                                    onChanged: (_) => toggleSelection(productId),
                                  ),
                                ),
                                DataCell(Text(product['productName'].toString())),
                                DataCell(Text(product['barcode'].toString())),
                                DataCell(Text(product['hsCode'].toString())),
                                DataCell(Text(product['costPrice'].toString())),
                                DataCell(Text(product['sellingPrice'].toString())),
                                DataCell(Text(product["tax"].toString())),
                                DataCell(Text(product["stockQty"].toString()))
                              ],
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                if (selectedProduct.isNotEmpty)
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
                    text: "Cancel",
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
