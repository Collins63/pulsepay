import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/reusable_text.dart';
//import 'package:pulsepay/authentication/login.dart';
import 'package:pulsepay/forms/view_products.dart';
import 'package:pulsepay/home/home_page.dart';

class AddProduct extends StatefulWidget{
  const AddProduct ({super.key});

  @override
  State<AddProduct> createState() => _AddproductState();
}

class _AddproductState extends State<AddProduct>{
  final productname = TextEditingController();
  final barcode = TextEditingController();
  final hsCodeController = TextEditingController();
  final costprice = TextEditingController();
  final sellingprice = TextEditingController();
  final vatBracket  = TextEditingController();
  final initStockController = TextEditingController();

  bool isVisible = false;
  bool vat15 = false;
  bool vat0 = false;
  bool vatEx  = false;

  void clearFields(){
    productname.clear();
    barcode.clear();
    hsCodeController.clear();
    costprice.clear();
    sellingprice.clear();
    vatBracket.clear();
    initStockController.clear();
    vat15 = false;
    vat0 = false;
    vatEx = false;
  }

  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255,255,255,255),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("Add Product" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset('assets/add-product.png'),
                        ),
                        const SizedBox(height: 15),
                        const SizedBox(height: 8,),
                        ReusableText(text: "Enter details below", style: appStyle(16, Colors.black,FontWeight.w500)),
                        const SizedBox(height: 24,),
                        //email address field
                        TextFormField(
                          controller: productname,
                          decoration: InputDecoration(
                              labelText: 'Product Name',
                              labelStyle: TextStyle(color:Colors.grey.shade600 ),
                              filled: true,
                              fillColor: Colors.white,
                              border:const OutlineInputBorder()
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Product name is required";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: barcode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'BarCode',
                            labelStyle:  TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            border:const OutlineInputBorder(
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Barcode Required";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: hsCodeController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'HsCode',
                            labelStyle:  TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            border:const OutlineInputBorder(
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Hs Code Required";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: costprice,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}$'), // allows whole numbers and decimals, up to 2 decimal places
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Cost Price',
                            labelStyle:  TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Cost Price Required";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: sellingprice,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}$'), // allows whole numbers and decimals, up to 2 decimal places
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Selling Price',
                            labelStyle:  TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            border:const OutlineInputBorder(
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Selling Price Required";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // TextFormField(
                        //   controller: vatBracket,
                        //   decoration: InputDecoration(
                        //     labelText: 'VAT Bracket',
                        //     labelStyle:  TextStyle(color: Colors.grey.shade600),
                        //     filled: true,
                        //     fillColor: Colors.white,
                        //     border: const OutlineInputBorder(
                        //     ),
                        //   ),
                        //   style: const TextStyle(color: Colors.black),
                        //   validator: (value){
                        //     if(value!.isEmpty){
                        //       return "VAT Bracket Required";
                        //     }return null;
                        //   },
                        // ),
                            CheckboxListTile(
                              title: ReusableText(text:"15% Vat" , style: appStyle(14, Colors.black,FontWeight.normal),),
                              value: vat15,
                              onChanged: (bool? value){
                                setState(() {
                                  vat15 = value!;
                                  if(vat15){
                                    vat0 = false;
                                    vatEx = false;
                                  }
                                });
                              }
                            ),
                            CheckboxListTile(
                              title: ReusableText(text:"Zero% Vat" , style: appStyle(14, Colors.black,FontWeight.normal),),
                              value: vat0,
                              onChanged: (bool? value){
                                setState(() {
                                  vat0 = value!;
                                  if(vat0){
                                    vat15 = false;
                                    vatEx = false;
                                  }
                                });
                              }
                            ),
                            CheckboxListTile(
                              title: ReusableText(text:"Exempted" , style: appStyle(14, Colors.black,FontWeight.normal),),
                              value: vatEx,
                              onChanged: (bool? value){
                                setState(() {
                                  vatEx = value!;
                                  if(vatEx){
                                    vat15 = false;
                                    vat0 = false;
                                  }
                                });
                              }
                            ),
                        const SizedBox(height: 16),
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: initStockController,
                          decoration: InputDecoration(
                            labelText: 'Stock Quantity',
                            labelStyle:  TextStyle(color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            border:const OutlineInputBorder(
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Put Zero dont leave blank";
                            }return null;
                          },
                        ),
                        const SizedBox(height: 20,),
                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  if(vat15 == false && vat0 == false && vatEx == false) {
                                    Get.snackbar(
                                      "Error",
                                      "Please select a VAT bracket",
                                      icon: const Icon(Icons.error),
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      snackPosition: SnackPosition.TOP
                                    );
                                    return;
                                   }else{
                                    final db = DatabaseHelper();
                                    await db.addProduct(Products(
                                      productName: productname.text,
                                      hsCode:int.parse(hsCodeController.text),
                                      barcode: barcode.text,
                                      sellingPrice: double.parse(sellingprice.text),
                                      costPrice: double.parse(costprice.text),
                                      tax: vat0 ? "zero" : vat15 ? "vat" : "ex" ,
                                      stockQty: int.parse(initStockController.text)
                                    ));
                                    Get.snackbar(
                                      "Success",
                                      "${productname.text} Added Successfully",
                                      icon: const Icon(Icons.check_circle),
                                      colorText: Colors.white,
                                      backgroundColor: Colors.green,
                                      snackPosition: SnackPosition.TOP
                                    );
                                    clearFields();
                                    setState(() {
                                      vat0 = false;
                                      vat15 = false;
                                      vatEx = false;
                                    });
                                   } 
                                  } catch (e) {
                                    Get.snackbar(
                                      "Error",
                                      "Error adding product: $e",
                                      icon:const Icon(Icons.error),
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      snackPosition: SnackPosition.TOP
                                    );
                                  }
                              }
      
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding:const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Add Product',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ); 
  }
}