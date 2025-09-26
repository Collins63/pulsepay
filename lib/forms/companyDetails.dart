import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/reusable_text.dart';

class Companydetails extends StatefulWidget {
  const Companydetails({super.key});

  @override
  State<Companydetails> createState() => _CompanydetailsState();
}

class _CompanydetailsState extends State<Companydetails> {

  @override
  void initState() {
    super.initState();
    fetchCompanyDetails();
    fetchTaxpayerDetails();
  }

  final companyID = TextEditingController();
  final company = TextEditingController();
  final logo = TextEditingController();
  final address = TextEditingController();
  final tel = TextEditingController();
  final branchName = TextEditingController();
  final tel2 = TextEditingController();
  final email = TextEditingController();
  final tinNumber = TextEditingController();
  final vatNumber = TextEditingController();
  final vendorNumber = TextEditingController();
  final website = TextEditingController();
  final bank = TextEditingController();
  final bankBranch = TextEditingController();
  final bankAcntName = TextEditingController();
  final bankAcntNo  = TextEditingController();
  final baseCurreny = TextEditingController();
  final backUpLocation = TextEditingController();
  final baseTaxPercentage = TextEditingController();

  final DatabaseHelper dbHelper  = DatabaseHelper();

  //taxpayer details
  final taxpayerName = TextEditingController();
  final taxPayerTin = TextEditingController();
  final taxPayerVat = TextEditingController();
  final deviceID = TextEditingController();
  final activationKey = TextEditingController();
  final deviceModelName = TextEditingController();
  final serialNo = TextEditingController();
  final modelVersionName = TextEditingController();


  List<Map<String, dynamic>> companyDetails = [];
  List<Map<String, dynamic>> taxPayerDetails = [];

  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  void clearFields(){
    company.clear();
    logo.clear();
    address.clear();
    tel.clear();
    branchName.clear();
    tel2.clear();
    email.clear();
    tinNumber.clear();
    vatNumber.clear();
    vendorNumber.clear();
    website.clear();
    bank.clear();
    bankBranch.clear();
    bankAcntName.clear();
    bankAcntNo.clear();
    baseCurreny.clear();
    backUpLocation.clear();
    baseTaxPercentage.clear();
  }

  void clearTaxDetails(){
    taxpayerName.clear();
    taxPayerTin.clear();
    taxPayerVat.clear();
    deviceID.clear();
    activationKey.clear();
    deviceModelName.clear();
    serialNo.clear();
    modelVersionName.clear();
  }

  Future<void> fetchCompanyDetails() async {
    List<Map<String, dynamic>> data = await dbHelper.getCompanyDetails();
    setState(() {
      companyDetails = data;
    });
  }

  Future<void> fetchTaxpayerDetails() async{
    List<Map<String, dynamic>> data = await dbHelper.getTaxPayerDetails();
    setState(() {
      taxPayerDetails = data;
    });
    print(data);
  }

  //=======================================add company details===================================
  addCompanyDetails(){
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
                        const Center(child: const Text("Customer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),           
                    SizedBox(height: 10,),
                                          const SizedBox(height: 24,),
                      //email address field
                      TextFormField(
                        controller: company,
                        decoration: InputDecoration(
                            labelText: 'Company',
                            labelStyle: TextStyle(color:Colors.grey.shade600 ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                            )
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Company name is required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: logo,
                        decoration: InputDecoration(
                          labelText: 'Logo',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: address,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tel,
                        decoration: InputDecoration(
                          labelText: 'Tel1',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: branchName,
                        decoration: InputDecoration(
                          labelText: 'Branch Name',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Branch Name Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tel2,
                        decoration: InputDecoration(
                          labelText: 'Tel 2',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tinNumber,
                        decoration: InputDecoration(
                          labelText: 'Tin Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Put 1234567890 If N/A";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:vatNumber,
                        decoration: InputDecoration(
                          labelText: 'Vat Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Put 123456789 If N/A";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vendorNumber,
                        decoration: InputDecoration(
                          labelText: 'Vendor Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: website,
                        decoration: InputDecoration(
                          labelText: 'Website',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: baseCurreny,
                        decoration: InputDecoration(
                          labelText: 'Base Currency',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "dont leave blank";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: backUpLocation,
                        decoration: InputDecoration(
                          labelText: 'Bank Up Location',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: baseTaxPercentage,
                        decoration: InputDecoration(
                          labelText: 'Base Tax',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "dont leave blank";
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
                                final db = DatabaseHelper();
                                await db.addCompanyDetails(CompanyDetails(
                                  company: company.text,
                                  logo: logo.text,
                                  address: address.text,
                                  tel: tel.text,
                                  branchName: branchName.text,
                                  email: email.text,
                                  tinNumber: tinNumber.text,
                                  vatNumber: vatNumber.text,
                                  vendorNumber: vendorNumber.text ,
                                  website: website.text ,
                                  baseCurreny: baseCurreny.text,
                                  backUpLocation: backUpLocation.text,
                                  baseTaxPercentage: baseTaxPercentage.text ,
                                ));
                                // Navigate to the HomePage after successful product addition
                                clearFields();
                                Navigator.pop(context);
                                 Get.snackbar(
                                  "Success",
                                  "Deatils added successfully",
                                  icon:const Icon(Icons.check),
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.TOP
                                );
                                } catch (e) {
                                  Get.snackbar(
                                    "Error",
                                    "Error adding details: $e",
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
                            'Save',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      
                      ),
                      const SizedBox(height: 20,)
                  ],
                
              ),
            ),
          ),
        );
      }
    );
  }

  //=======================================Update company details===================================
  updateCompanyDetails(){
    int compID = companyDetails[0]['companyID'];

    company.text = companyDetails.isNotEmpty ? companyDetails[0]['company'] ?? '' : '';
    address.text = companyDetails.isNotEmpty ? companyDetails[0]['address'] ?? '' : '';
    tel.text = companyDetails.isNotEmpty ? companyDetails[0]['tel']?? '' : '';
    branchName.text = companyDetails.isNotEmpty ? companyDetails[0]['branchName'] ?? '' : '';
    tel2.text = companyDetails.isNotEmpty ? companyDetails[0]['tel2'] ?? '' : '';
    email.text = companyDetails.isNotEmpty ? companyDetails[0]['email'] ?? '' : '';
    tinNumber.text = companyDetails.isNotEmpty ? companyDetails[0]['tinNumber'] ?? '' : '';
    vatNumber.text = companyDetails.isNotEmpty ? companyDetails[0]['vatNumber'] ?? '' : '';
    vendorNumber.text = companyDetails.isNotEmpty ? companyDetails[0]['vendorNumber'] ?? '' : '';
    website.text = companyDetails.isNotEmpty ? companyDetails[0]['website'] ?? '' : '';
    baseCurreny.text = companyDetails.isNotEmpty ? companyDetails[0]['baseCurrency'] ?? '' : '';
    backUpLocation.text = companyDetails.isNotEmpty ? companyDetails[0]['backUpLocation'] ?? '' : '';
    baseTaxPercentage.text  = companyDetails.isNotEmpty? companyDetails[0]['baseTaxPercentage'].toString() ?? '' : '';

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
                        const Center(child: const Text("Customer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),           
                    SizedBox(height: 10,),
                      const SizedBox(height: 24,),
                      //email address field
                      TextFormField(
                        controller: company,
                        decoration: InputDecoration(
                            labelText: 'Company',
                            labelStyle: TextStyle(color:Colors.grey.shade600 ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                            )
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Company name is required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: address,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tel,
                        decoration: InputDecoration(
                          labelText: 'Tel1',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: branchName,
                        decoration: InputDecoration(
                          labelText: 'Branch Name',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Branch Name Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tel2,
                        decoration: InputDecoration(
                          labelText: 'Tel 2',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tinNumber,
                        decoration: InputDecoration(
                          labelText: 'Tin Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Put 1234567890 If N/A";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:vatNumber,
                        decoration: InputDecoration(
                          labelText: 'Vat Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Put 123456789 If N/A";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vendorNumber,
                        decoration: InputDecoration(
                          labelText: 'Vendor Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: website,
                        decoration: InputDecoration(
                          labelText: 'Website',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: baseCurreny,
                        decoration: InputDecoration(
                          labelText: 'Base Currency',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "dont leave blank";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: backUpLocation,
                        decoration: InputDecoration(
                          labelText: 'Bank Up Location',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: baseTaxPercentage,
                        decoration: InputDecoration(
                          labelText: 'Base Tax',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "dont leave blank";
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
                                final db = DatabaseHelper();
                                await db.updateCompanyDetails(
                                  compID, 
                                  company.text.toUpperCase(),
                                  logo.text.toUpperCase(),
                                  address.text.toUpperCase(),
                                  tel.text.toUpperCase(),
                                  branchName.text.toUpperCase(),
                                  tel2.text.toUpperCase(),
                                  email.text,
                                  tinNumber.text,
                                  vatNumber.text,
                                  vendorNumber.text,
                                  website.text,
                                  baseCurreny.text.toUpperCase(),
                                  backUpLocation.text,
                                  baseTaxPercentage.text
                                );
                                clearFields();
                                Navigator.pop(context);
                                 Get.snackbar(
                                  "Success",
                                  "Company details updated successfully",
                                  icon:const Icon(Icons.check),
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.TOP
                                );
                                } catch (e) {
                                  Get.snackbar(
                                    "Error",
                                    "Error updating details: $e",
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
                            'Updated Company Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      
                      ),
                      const SizedBox(height: 20,)
                  ],
                
              ),
            ),
          ),
        );
      }
    );
  }

  //=======================add taxpayer details============================================
  addTaxpayerDetails(){
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
                        const Center(child: const Text("Tax Payer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),           
                    SizedBox(height: 10,),
                                          const SizedBox(height: 24,),
                      //email address field
                      TextFormField(
                        controller: taxpayerName,
                        decoration: InputDecoration(
                            labelText: 'Trade Name',
                            labelStyle: TextStyle(color:Colors.grey.shade600 ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                            )
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Company name is required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: taxPayerTin,
                        decoration: InputDecoration(
                          labelText: 'TIN Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: taxPayerVat,
                        decoration: InputDecoration(
                          labelText: 'VAT Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: deviceID,
                        decoration: InputDecoration(
                          labelText: 'Device ID',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: activationKey,
                        decoration: InputDecoration(
                          labelText: 'Activation Key',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: deviceModelName,
                        decoration: InputDecoration(
                          labelText: 'Device Model Name',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: serialNo,
                        decoration: InputDecoration(
                          labelText: 'Serail No',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: modelVersionName,
                        decoration: InputDecoration(
                          labelText: 'Device Model Versiion',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
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
                                final db = DatabaseHelper();
                                await db.addTaxPayerDetails(TaxPayer(
                                  taxPayerName: taxpayerName.text,
                                  taxPayerTin: taxPayerTin.text,
                                  taxPayerVatNumber: taxPayerVat.text,
                                  deviceID: int.tryParse(deviceID.text)!,
                                  activationKey: activationKey.text,
                                  deviceModelName: deviceModelName.text,
                                  serialNo: serialNo.text,
                                  deviceModelVersion: modelVersionName.text,
                                ));
                                // Navigate to the HomePage after successful product addition
                                //clearTaxDetails();
                                Navigator.pop(context);
                                 Get.snackbar(
                                  "Success",
                                  "Details added successfully",
                                  icon:const Icon(Icons.check),
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.TOP
                                );
                                } catch (e) {
                                  Get.snackbar(
                                    "Error",
                                    "Error adding details: $e",
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
                            'Add TaxPayer Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      
                      ),
                      const SizedBox(height: 20,)
                  ],
                
              ),
            ),
          ),
        );
      }
    );
  }


  //=======================update taxpayer details============================================
  updateTaxpayerDetails(){
    int taxPayerId = taxPayerDetails[0]['taxPayerId'];
    //taxPayerTin.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['taxPayerTin'].toString() : '';
    taxpayerName.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['taxPayerName'].toString()  : '';
    taxPayerTin.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['taxPayerTin'].toString() : '';
    taxPayerVat.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['taxPayerVatNumber'].toString() : '' ;
    deviceID.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['deviceID'].toString() : '' ;
    activationKey.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['activationKey'].toString() : '';
    deviceModelName.text =taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['deviceModelName'].toString() : '' ;
    serialNo.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['serialNo'].toString() : '';
    modelVersionName.text = taxPayerDetails.isNotEmpty ? taxPayerDetails[0]['deviceModelVersion'].toString() : '';

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
                        const Center(child: const Text("Tax Payer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),           
                    SizedBox(height: 10,),
                    const SizedBox(height: 24,),
                      //email address field
                      TextFormField(
                        controller: taxpayerName,
                        decoration: InputDecoration(
                            labelText: 'Trade Name',
                            labelStyle: TextStyle(color:Colors.grey.shade600 ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                            )
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Company name is required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: taxPayerTin,
                        decoration: InputDecoration(
                          labelText: 'TIN Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: taxPayerVat,
                        decoration: InputDecoration(
                          labelText: 'VAT Number',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: deviceID,
                        decoration: InputDecoration(
                          labelText: 'Device ID',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: activationKey,
                        decoration: InputDecoration(
                          labelText: 'Activation Key',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: deviceModelName,
                        decoration: InputDecoration(
                          labelText: 'Device Model Name',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: serialNo,
                        decoration: InputDecoration(
                          labelText: 'Serail No',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
                          }return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: modelVersionName,
                        decoration: InputDecoration(
                          labelText: 'Device Model Versiion',
                          labelStyle:  TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value){
                          if(value!.isEmpty){
                            return "Field Required";
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
                                final db = DatabaseHelper();
                                await db.updateTaxpayerDetails(taxPayerId , taxPayerTin.text , taxpayerName.text , taxPayerVat.text ,int.tryParse(deviceID.text)! ,
                                activationKey.text , deviceModelName.text , serialNo.text , modelVersionName.text);
                                // Navigate to the HomePage after successful product addition
                                clearTaxDetails();
                                Navigator.pop(context);
                                 Get.snackbar(
                                  "Success",
                                  "Details Updated successfully",
                                  icon:const Icon(Icons.check),
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.TOP
                                );
                                } catch (e) {
                                  Get.snackbar(
                                    "Error",
                                    "Error adding details: $e",
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
                            'Update TaxPayer Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      
                      ),
                      const SizedBox(height: 20,)
                  ],
                
              ),
            ),
          ),
        );
      }
    );
  }
  

  Widget build(BuildContext context) {
  return Scaffold(
        backgroundColor: const Color.fromARGB(255,255,255,255),
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
          title: const Text("Company Details" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16 , color: Colors.white),),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const SizedBox(height: 8,),
                        Text(
                          "Enter company details below",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Container(
                          height:350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kDark,
                          ) ,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0 ,top: 10.0),
                            child: ListView(
                              children: [
                                Text("COMPNAY NAME: ${companyDetails.isEmpty?"N/A" : companyDetails[0]['company'] } " , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16),),
                                const SizedBox(height: 6,),
                                Text("BRANCH: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['branchName']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("ADDRESS: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['address'] }" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("TEL: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['tel'] } " , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("EMAIL: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['email']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("TIN: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['tinNumber']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("VAT: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['vatNumber']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("BASE CURRENCY: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['baseCurreny'] }" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("BASE TAX: ${companyDetails.isEmpty? "N/A" : companyDetails[0]['baseTaxPercentage']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25,),
                        CustomOutlineBtn(
                          text: "Enter Company Details",
                          height: 50,
                          color: Colors.blue,
                          color2: Colors.blue,
                          onTap: (){
                            addCompanyDetails();
                          },
                        ),
                        SizedBox(height: 20,),
                        CustomOutlineBtn(
                          text: "Update Company Details",
                          height: 50,
                          color: Colors.orange,
                          color2: Colors.orange,
                          onTap: (){
                            //Get.to(()=> const Companydetails());
                            updateCompanyDetails();
                          },
                        ),
                        const SizedBox(height: 40,),
                        Text(
                          "Enter FDMS Tax Payer Details",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Container(
                          height:350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kDark,
                          ) ,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0 ,top: 10.0),
                            child: ListView(
                              children: [
                                Text("TAXPAYER NAME: ${taxPayerDetails.isEmpty ? "N/A" : taxPayerDetails[0]['taxPayerName'] } " , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16),),
                                const SizedBox(height: 6,),
                                Text("TIN NUMBER: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['taxPayerTin']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("VAT NUMBER: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['taxPayerVatNumber'] }" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("DEVICE ID: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['deviceID'] } " , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("ACTIVATION KEY: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['activationKey']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("MODEL NAME: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['deviceModelName']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("SERIAL NUMBER: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['serialNo']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                                const SizedBox(height: 6,),
                                Text("MODEL VERSION: ${taxPayerDetails.isEmpty? "N/A" : taxPayerDetails[0]['deviceModelVersion']}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16))
                              ]
                            ),
                          ),
                        ),
                        const SizedBox(height: 25,),
                        CustomOutlineBtn(
                          text: "Enter Tax Payer Details",
                          height: 50,
                          color: Colors.blue,
                          color2: Colors.blue,
                          onTap: (){
                            addTaxpayerDetails();
                          },
                        ),
                        SizedBox(height: 20,),
                        CustomOutlineBtn(
                          text: "Update Tax Payer Details",
                          height: 50,
                          color: Colors.orange,
                          color2: Colors.orange,
                          onTap: (){
                            //Get.to(()=> const Companydetails());
                            updateTaxpayerDetails();
                          },
                        ),
                      ],
                    ),
                ),
              ),
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){clearFields();},
        //   backgroundColor: kDark,
        //   elevation: 4.0,
        //   child: const Icon(Icons.refresh_rounded , color: Colors.white,),
        // ),
      ); 
    }
}