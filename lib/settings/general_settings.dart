import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {

  bool isFiscal = false;
  bool barcodeOption = false;
  bool freePricingMode = false;
  bool allowNegativeSale = false;
  bool accountSale = false;
  bool priceDiscount = false;
  bool multiCurrencySale = false;
  bool a4Invoice = false;
  bool hasBluetoothPrinter = false;
  bool isTabView = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved preference
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFiscal = prefs.getBool('isFiscal') ?? false; // default = false
      barcodeOption = prefs.getBool('hasBarcode') ?? false;
      freePricingMode = prefs.getBool('hasFreePrice') ?? false;
      allowNegativeSale = prefs.getBool('hasNegativeSales') ?? false;
      accountSale = prefs.getBool('hasAccountSales') ?? false;
      priceDiscount = prefs.getBool('hasInvoiceDiscount') ?? false;
      multiCurrencySale = prefs.getBool('hasMultiCurrencySale') ?? false;
      a4Invoice = prefs.getBool('hasA4Invoice') ?? false;
      hasBluetoothPrinter = prefs.getBool('hasBluetoothPrinter') ?? false;
      isTabView = prefs.getBool('isTabView') ?? false;
    });
  }

  // Save preference
  Future<void> _saveFiscalSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFiscal', value);
  }

  Future<void> _saveBluetoothPrinter(bool value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasBluetoothPrinter", value);
  }

  Future<void> _saveViewSetting(bool value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isTabView", value);
  }

  Future<void> _saveMultiCurrencySetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasMultiCurrencySale', value);
  }

  Future<void> _saveA4InvoiceSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasA4Invoice', value);
  }

  Future<void> _barcodeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasBarcode', value);
  }

  Future<void> _saveFreePriceSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasFreePrice', value);
  }

  Future<void> _saveNegativeSaleSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasNegativeSales', value);
  }

  Future<void> _saveAccountSaleSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccountSales', value);
  }

  Future<void> _saveDiscountSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasInvoiceDiscount', value);
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text("General Settings" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16 , color: Colors.white),),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Heading(text: "Point of Sale Terminal"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Has Tab View", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: isTabView , onChanged: (value){
                    setState(() {
                      isTabView = value;
                    });
                     _saveViewSetting(value);
                  })
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "IsFiscal", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: isFiscal , onChanged: (value){
                    setState(() {
                      isFiscal = value;
                    });
                     _saveFiscalSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Free Pricing Mode", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: freePricingMode , onChanged: (value){
                    setState(() {
                      freePricingMode = value;
                    });
                     _saveFreePriceSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Allow Negative Sale", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: allowNegativeSale , onChanged: (value){
                    setState(() {
                      allowNegativeSale = value;
                    });
                     _saveNegativeSaleSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Barcode Option", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: barcodeOption , onChanged: (value){
                    setState(() {
                      barcodeOption = value;
                    });
                     _barcodeSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Account Sale", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: accountSale , onChanged: (value){
                    setState(() {
                      accountSale = value;
                    });
                     _saveAccountSaleSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Price Discount", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: priceDiscount , onChanged: (value){
                    setState(() {
                      priceDiscount = value;
                    });
                     _saveDiscountSetting(value);
                  })
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Multi Currency Sale", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: multiCurrencySale , onChanged: (value){
                    setState(() {
                      multiCurrencySale = value;
                    });
                     _saveMultiCurrencySetting(value);
                  })
                ],
              ),
              const SizedBox(height: 20,),
              const Heading(text: "Receipt Settings"),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "A4 Invoice", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: a4Invoice , onChanged: (value){
                    setState(() {
                      a4Invoice = value;
                    });
                     _saveA4InvoiceSetting(value);
                  })
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Has Bluetooth Printer", style: appStyle(14, Colors.grey, FontWeight.w500)),
                  Switch(
                    activeColor: Colors.blueAccent,
                    value: hasBluetoothPrinter , onChanged: (value){
                    setState(() {
                      hasBluetoothPrinter = value;
                    });
                     _saveBluetoothPrinter(value);
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}