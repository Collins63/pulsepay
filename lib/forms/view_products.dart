import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/authentication/login.dart';
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
  List<Map<String, dynamic>> productFromID = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllProducts();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  Future<void> deleteProduct(int productId) async{
    try {
      await dbHelper.deleteProduct(productId);
      Get.snackbar("Deletion Success",
        "Product Deleted Successfully",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.message, color: Colors.white),
      );
      fetchProducts();
    } catch (e) {
      Get.snackbar("Delete Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Future<void> fetchProductById(int id) async{
    List<Map<String, dynamic>> data = await dbHelper.getProductById(id);
    setState(() {
      productFromID = data;
      isLoading = false;
      showUpdatePrompt();
    });
  }

  showUpdatePrompt(){
    final TextEditingController nameController = TextEditingController();
    final TextEditingController barcodeController = TextEditingController();
    final TextEditingController hcodeController = TextEditingController();
    final TextEditingController costPriceController = TextEditingController();
    final TextEditingController sellingController = TextEditingController();
    final TextEditingController taxController = TextEditingController();

    nameController.text = productFromID.isNotEmpty ? productFromID[0]['productName'].toString() : '';
    barcodeController.text = productFromID.isNotEmpty ? productFromID[0]['barcode'].toString() : '';
    hcodeController.text = productFromID.isNotEmpty ? productFromID[0]['hsCode'].toString() : '';
    barcodeController.text = productFromID.isNotEmpty ? productFromID[0]['barcode'].toString() : '';
    costPriceController.text = productFromID.isNotEmpty ? productFromID[0]['costPrice'].toString() : '';
    sellingController.text = productFromID.isNotEmpty ? productFromID[0]['sellingPrice'].toString() : '';
    taxController.text = productFromID.isNotEmpty ? productFromID[0]['tax'].toString() : '';
    int productid = productFromID.isNotEmpty ? productFromID[0]['productid'] : 0;

    showDialog(
      context: context,
      barrierDismissible:  false,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Update Product"),
          content:SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Type In Fields To Update Product"),
                const SizedBox(height: 10,),
                TextField(
                  controller: nameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: barcodeController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Bar Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: hcodeController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'HS Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: costPriceController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Cost Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: sellingController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Selling Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: taxController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    labelText: 'Tax',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ) ,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
            onPressed: () {
              String name = nameController.text;
              String barcode = barcodeController.text;
              String hscode = hcodeController.text;
              String costPrice = costPriceController.text;
              String sellingPrice = sellingController.text;
              String tax = taxController.text;
              dbHelper.updateProduct(productid, name, barcode, hscode, costPrice, sellingPrice, tax).then((_) {
                Navigator.of(context).pop(); // Close the dialog
                fetchProducts();// Refresh the product list
                Get.snackbar(
                  'Product Update', 'Product Updated Successfully',
                  snackPosition: SnackPosition.TOP,
                  colorText: Colors.white,
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.message, color: Colors.white),
                );
              });
            },
            child: const Text('Update'),
          ),
          ],
        );
      }
    );

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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: (){Get.back();},
          icon: const Icon(Icons.arrow_circle_left_outlined , color: Colors.white ,size: 30,),
        ),
        centerTitle: true,
        title: const Text("Edit Products" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16 , color: Colors.white),),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
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
                          DataColumn(label: Text('ProductName')),
                          DataColumn(label: Text('BarCode')),
                          DataColumn(label: Text('HS Code')),
                          DataColumn(label: Text('costPrice')),
                          DataColumn(label: Text("SellingPrice")),
                          DataColumn(label: Text('TAX')),
                          DataColumn(label: Text('Stock QTY')),
                          DataColumn(label: Text('Actions'))
                        ],
                        rows: products
                            .map(
                              (product) {
                                final productId = product['productid'];
                                return DataRow(
                                  selected: selectedProduct.contains(productId),
                                  onSelectChanged: (selected) {
                                    toggleSelection(productId);
                                  },
                                cells: [
                                  DataCell(Text(product['productName'].toString())),
                                  DataCell(Text(product['barcode'].toString())),
                                  DataCell(Text(product['hsCode'].toString())),
                                  DataCell(Text(product['costPrice'].toString())),
                                  DataCell(Text(product['sellingPrice'].toString())),
                                  DataCell(Text(product["tax"].toString())),
                                  DataCell(Text(product["stockQty"].toString())),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                             fetchProductById(productId);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title:  const Text("Confirm Deletion"),
                                                  content:const Column(
                                                    mainAxisSize: MainAxisSize.min ,
                                                    children: [
                                                      Text("Are you sure you want to delete this product?"),
                                                      SizedBox(height: 10,),
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
                                                    onPressed: () async {
                                                      await deleteProduct(productId);
                                                      Navigator.of(context).pop(); // Close the dialog   
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                  ],
                                                );
                                              }
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
              ],
            ),
          ),

    );
  }
}
