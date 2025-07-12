import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/forms/stock_management.dart';
import 'package:sqflite/sqflite.dart';

class BulkStockEntry extends StatefulWidget {
  const BulkStockEntry({super.key});

  @override
  State<BulkStockEntry> createState() => _BulkStockEntryState();
}

class _BulkStockEntryState extends State<BulkStockEntry> {

  DatabaseHelper dbHelper  = DatabaseHelper();

  Future<void> importCSV() async {

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      final file = File(result.files.single.path!);
      final csvContent = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvContent, eol: '\n');

      List<Map<String, dynamic>> products = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        products.add({
          'productName': row[0],
          'barcode': row[1],
          'hsCode': row[2],
          'costPrice': row[3],
          'sellingPrice': row[4],
          'sellqty': row[5],
          'tax': row[6],
          'stockQty': row[7],
        });
      }

      await dbHelper.insertBulkProducts(products);
      print('✅ Bulk import from CSV complete!');
      Get.snackbar("Import Sucess", "Bulk Entry Done" , snackPosition: SnackPosition.TOP , backgroundColor: Colors.green , colorText: Colors.white, icon: Icon(Icons.done));
    }
    } catch (e) {
       Get.snackbar("Import Error", "$e" , snackPosition: SnackPosition.TOP , backgroundColor: Colors.red , colorText: Colors.white , icon: Icon(Icons.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StockManagement()));
            },
            icon: const Icon(Icons.arrow_circle_left_outlined , color: Colors.white ,size: 30,),
          ),
          centerTitle: true,
          title: const Text("Bulk Entry" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16 , color: Colors.white),),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              CustomOutlineBtn(
                text: "Enter Bulk Stock",
                color: Colors.green,
                color2: Colors.green,
                height: 40,
                onTap: (){
                  importCSV();
                },
              )
          ],),
        ),
      ),
    );
  }
}