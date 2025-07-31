import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({super.key});

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  final formKey = GlobalKey<FormState>();
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> payMethods = [];
  List<int> selectedMethod = [];
  bool isLoading = true;
  final descriptionController = TextEditingController();
  final rateController = TextEditingController();
  final fiscGroupController = TextEditingController();
  final currencyController = TextEditingController();
  final vatNumberController = TextEditingController();
  final tinController = TextEditingController();
  List<Map<String, dynamic>> payMethodFromID = [];

  @override
  void initState() {
    super.initState();
    fetchPayMethods();
  }

  void clearFields(){
    descriptionController.clear();
    rateController.clear();
    fiscGroupController.clear();
    currencyController.clear();
    vatNumberController.clear();
    tinController.clear();
  }

  Future<void> fetchPayMethods() async {
    List<Map<String, dynamic>> data = await dbHelper.getPaymentMethods();
    setState(() {
      payMethods = data;
      isLoading = false;
    });
  }

  void toggleSelection(int productId) {
    setState(() {
      if (selectedMethod.contains(productId)) {
        selectedMethod.remove(productId);
      } else {
        selectedMethod.add(productId);
      }
    });
  }

  void deleteByID(int methodId) async{
    if(methodId != 0){
      await  dbHelper.deletePayMethod(methodId);
      Get.snackbar("Delete Message", " deleted successfully!!",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.message_outlined)
      );
    }
  }

   Future<void> fetchMethodById(int id) async{
    List<Map<String, dynamic>> data = await dbHelper.getPaymentMethodById(id);
    setState(() {
      payMethodFromID = data;
      isLoading = false;
      showUpdatePrompt();
    });
  }


  ///=====Add Paymethods=====//////////
  //////////////////////////////////////
  addPaymethods(){
    return showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context){
        return Container(
          height: 600,
          child: Padding(
            padding:  EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom
            ),
            child: Form(
              key: formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: kDark,
                          borderRadius: BorderRadius.circular(20), 
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        }, icon:const Icon(Icons.arrow_circle_left_sharp, size: 40, color: kDark,)),
                        const Center(child: const Text("Payment Method" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: rateController,
                      decoration: InputDecoration(
                          labelText: 'Rate',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Rate Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: fiscGroupController,
                      decoration: InputDecoration(
                          labelText: 'Fiscal Group',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Group Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: currencyController,
                      decoration: InputDecoration(
                          labelText: 'Currency',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Currency Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: vatNumberController ,
                      decoration: InputDecoration(
                          labelText: 'Vat Number',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    
                    TextFormField(
                      controller: tinController ,
                      decoration: InputDecoration(
                          labelText: 'Tin Number',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          try {
                            if(formKey.currentState!.validate()){
                            final db = DatabaseHelper();
                            await db.addPayMethod(PaymentMethod(
                              description: descriptionController.text.toUpperCase(),
                              rate: double.parse(rateController.text.trim()),
                              fiscalGroup: int.parse(fiscGroupController.text.trim()),
                              currency: currencyController.text.trim().toUpperCase(),
                              vatNumber: vatNumberController.text.trim(),
                              tinNumber: tinController.text.trim(),
                            ));
                            clearFields();
                            Navigator.pop(context);
                            Get.snackbar(
                              'Success',
                              'Payment Method Saved',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white
                            );
                            fetchPayMethods();
                          }
                          } catch (e) {
                            Get.snackbar(
                              "Error Saving", "$e",
                              icon:const Icon(Icons.error),
                              colorText: Colors.white,
                              backgroundColor: Colors.red,
                              snackPosition: SnackPosition.TOP
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Save Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                
              ),
            ),
          ),
        );
      }
    );
  }

  ///Update Payment Method
  ///
  //////////////////////////////////////////
  showUpdatePrompt(){

    descriptionController.text = payMethodFromID.isNotEmpty ? payMethodFromID[0]['description'].toString() : '';
    rateController.text = payMethodFromID.isNotEmpty ? payMethodFromID[0]['rate'].toString() : '';
    fiscGroupController.text = payMethodFromID.isNotEmpty ? payMethodFromID[0]['fiscalGroup'].toString() : '';
    currencyController.text = payMethodFromID.isNotEmpty ? payMethodFromID[0]['currency'].toString() : '';
    int payMethodId = payMethodFromID.isNotEmpty ? payMethodFromID[0]['payMethodId'] : 0;

    showDialog(
      context: context,
      barrierDismissible:  false,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Update Product"),
          content:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Type In Fields To Update Product"),
              const SizedBox(height: 10,),
              TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: rateController,
                      decoration: InputDecoration(
                          labelText: 'Rate',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Rate Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: fiscGroupController,
                      decoration: InputDecoration(
                          labelText: 'Fiscal Group',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Group Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: currencyController,
                      decoration: InputDecoration(
                          labelText: 'Currency',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "Currency Required";
                          }return null;
                        },
                    ),
              const SizedBox(height: 10,),
            ],
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
              String description = descriptionController.text;
              double rate = double.tryParse(rateController.text) ?? 0.0;
              String fiscGroup = fiscGroupController.text;
              String currency = currencyController.text;
              dbHelper.updatePaymentMethod(payMethodId, description, rate, fiscGroup, currency).then((_) {
                Navigator.of(context).pop();
                fetchPayMethods();
                Get.snackbar(
                  'Currency Update', 'Currency Updated Successfully',
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


  void setDefaultCurrency(int methodId){
    int defaultTag =1;
    try {
      dbHelper.setDefaultCurrency(methodId, defaultTag);
      Get.snackbar(
        "Success", "Default Currency Set",
        icon:const Icon(Icons.check),
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.TOP,
        showProgressIndicator: true,
      );
      fetchPayMethods();
    } catch (e) {
      Get.snackbar(
        "Error", "$e",
        icon: Icon(Icons.error),
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP
      );
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
              Get.back();
            },
            icon: const Icon(Icons.arrow_circle_left_outlined , color: Colors.white ,size: 30,),
          ),
          centerTitle: true,
          title: const Text("Payment Methods" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16 , color: Colors.white),),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child:Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                CustomOutlineBtn(text: "Add Payment Method", color: Colors.blue ,color2: Colors.blue, height: 50, onTap: (){addPaymethods();},),
                const SizedBox(height: 25,),
                const Center(child: Text("Available Pay Methods" , style: TextStyle(fontWeight: FontWeight.w500),)),
                const SizedBox(height: 10,),
                isLoading? const Center(child: CircularProgressIndicator(),)
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          headingRowColor: MaterialStateProperty.all(Colors.blue),
                          columns: const[
                            DataColumn(label: Text("Description")),
                            DataColumn(label: Text("Rate")),
                            DataColumn(label: Text("Fiscal Group")),
                            DataColumn(label: Text("Currency")),
                            DataColumn(label: Text("VAT Number")),
                            DataColumn(label: Text("TIN Number")),
                            DataColumn(label: Text("default")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: payMethods.map((paymentMethod){
                            final methodId = paymentMethod['payMethodId'];
                            return DataRow(
                              selected: selectedMethod.contains(methodId),
                                  onSelectChanged: (selected) {
                                    toggleSelection(methodId);
                              },
                              cells: [
                                DataCell(Text(paymentMethod['description'].toString())),
                                DataCell(Text(paymentMethod['rate'].toString())),
                                DataCell(Text(paymentMethod['fiscalGroup'].toString())),
                                DataCell(Text(paymentMethod['currency'].toString())),
                                DataCell(Text(paymentMethod['vatNumber'].toString())),
                                DataCell(Text(paymentMethod['tinNumber'].toString())),
                                DataCell(Text(paymentMethod['defaultMethod'].toString())),
                                DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                             fetchMethodById(methodId);
                                          },
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            setDefaultCurrency(methodId);
                                          },
                                          icon:const Icon(Icons.settings_accessibility ,color: Colors.orange,)
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
                                                      deleteByID(methodId);
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
                              ]
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}