import 'dart:convert';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_field.dart';
import 'package:get/get.dart';
import 'package:pulsepay/fiscalization/sslContextualization.dart';
import 'package:pulsepay/fiscalization/submitReceipts.dart';
//import 'package:pulsepay/home/home_page.dart';

class Pos  extends StatefulWidget{
  const Pos({super.key});
  @override
  State<Pos> createState() => _PosState();
}

class _PosState extends State<Pos>{
  bool isBarcodeEnabled = false;
  @override
  void initState() {
    super.initState();
    fetchPayMethods();
    fetchDefaultPayMethod();
    fetchDefaultCurrency();
    fetchDefaultRate();
    //initializePrivateKey();
  }

  late String privateKey;

  final TextEditingController controller = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController searchCustomer = TextEditingController();
  final DatabaseHelper dbHelper  = DatabaseHelper();


  List<Map<String , dynamic>> defaultPayMethod = [];
  List<Map<String, dynamic>> payMethods = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> customerDetails = [];
  List<Map<String, dynamic>> selectedCustomer =[];
  List<Map<String, dynamic>> selectedPayMethod =[];
  List<Map<String, dynamic>> productOnSale =[];
  final formKey = GlobalKey<FormState>();
  final paidKey = GlobalKey<FormState>();
  bool isActve = true;
  String? defaultCurrency;
  double? defaultRate;

  List<Map<String, dynamic>> receiptItems = [];
  double totalAmount = 0.0; 
  double taxAmount = 0.0;
  String? generatedJson;
  String? fiscalResponse;
  double taxPercent = 0.0 ;
  String? taxCode;
  double salesAmountwithTax =0.0;
  String? encodedSignature;
  String? encodedHash;
  

  Future<bool> requestStoragePermission() async {
  if (await Permission.storage.isGranted) {
    return true;
  }
  
  var status = await Permission.storage.request();
  return status.isGranted;
}

  void addItem() {
  for (var item in cartItems) {
    double itemTotal = (item['sellingPrice'] is String) 
        ? double.parse(item['sellingPrice']) 
        : item['sellingPrice'].toDouble();
    
    int quantity = (item['sellqty'] is String) 
        ? int.parse(item['sellqty']) 
        : item['sellqty'];

    double totalPrice = itemTotal * quantity;
    double itemTax;
    int taxID;
    String taxCode;
    double taxPercent;
    
    String productTax = item['tax'] ?? ""; // Handle null case

    if (productTax == "zero") {
      taxID = 1;
      taxPercent = 0.0;
      taxCode = "A";
      itemTax = totalPrice * taxPercent;
    } else if (productTax == "vat") {
      taxID = 3;
      taxPercent = 15.00; // Convert 15% to decimal
      taxCode = "C";
      itemTax = totalPrice * (taxPercent / 100);
      salesAmountwithTax += totalPrice;
    } else {
      taxID = 2;
      taxPercent = 0.00;
      taxCode = "B";
      itemTax = totalPrice * taxPercent;
    }

    setState(() {
      receiptItems.add({
        'productName': item['productName'],
        'price': itemTotal,
        'quantity': quantity,
        'total': totalPrice,
        'taxID': taxID,
        'taxPercent': taxPercent,
        'taxCode': taxCode,
      });
    });

    totalAmount += totalPrice;
    taxAmount += itemTax;
  }
}

  Future<RSAPrivateKey?> loadPrivateKeyFromP12(String filePath, String password) async {
  // Load the `.p12` file
  Uint8List p12Bytes = await File(filePath).readAsBytes();

  // Parse PKCS#12 file
   var p12 = Pkcs12Utils.parsePkcs12( p12Bytes, password: password);

  // Extract private key as PEM
  String? privateKeyPem = p12.privateKey;

  if (privateKeyPem != null) {
    return CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem); // Convert to RSAPrivateKey
  } else {
    print("❌ No private key found in the .p12 file.");
    return null;
  }
}

  /// Generate JSON after sale
  generateFiscalJSON() async {
    String p12FilePath = "path/to/your_certificate.p12";
  String p12Password = "your_password";

  // Load the private key from the .p12 file
  RSAPrivateKey? privateKey = await loadPrivateKeyFromP12(p12FilePath, p12Password);

  if (privateKey != null) {
    String dataToSign = "Signature_raw";
    
    // Generate the digital signature
    String deviceSignature = generateDeviceSignature(dataToSign, privateKey);
    print("Device Signature: $deviceSignature");
  } else {
    print("❌ Unable to sign data because the private key could not be loaded.");
  }
    
    try {
      String privateKeyPem = await readPrivateKeyFromStorage();
      final logger = Logger();
      logger.d(privateKeyPem);
      RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
      String hash =await generateHash();
    String signature = await generateDeviceSignature(hash , privateKey );
    String nextInvoice = dbHelper.getNextInvoiceId().toString();
    String saleCurrency;
    if (receiptItems.isEmpty) return "{}";
    if (selectedPayMethod.isEmpty){
      saleCurrency = defaultCurrency.toString();
    }else{
      saleCurrency = returnCurrency();
    }
    Map<String, dynamic> jsonData = {
  "receipt": {
    "receiptLines": receiptItems.asMap().entries.map((entry) {
      int index = entry.key + 1;
      var item = entry.value;
      return {
        "receiptLineNo": "$index",
        "receiptLineHSCode": "99001000",
        "receiptLinePrice": item["price"].toStringAsFixed(2),
        "taxID": item["taxID"],
        "taxPercent": item["taxPercent"].toStringAsFixed(2),
        "receiptLineType": "Sale",
        "receiptLineQuantity": item["quantity"].toString(),
        "taxCode": item["taxCode"],
        "receiptLineTotal": item["total"].toStringAsFixed(2),
        "receiptLineName": item["productName"]
      };
    }).toList(),
    "receiptType": "FISCALINVOICE",
    "receiptGlobalNo": 2,
    "receiptCurrency": "$saleCurrency",
    "receiptPrintForm": "InvoiceA4",
    "receiptDate": DateTime.now().toIso8601String(),
    "receiptPayments": [
      {"moneyTypeCode": "Cash", "paymentAmount": totalAmount.toStringAsFixed(2)}
    ],
    "receiptCounter": 1,
    "receiptTaxes": generateReceiptTaxes(receiptItems), // Call the function here
    "receiptDeviceSignature": {
      "signature":signature ,
      "hash": hash,
    },
    "buyerData": {
      "VATNumber": "123456789",
      "buyerTradeName": "SAT ",
      "buyerTIN": "0000000000",
      "buyerRegisterName": "SAT "
    },
    "receiptTotal": totalAmount.toStringAsFixed(2),
    "receiptLinesTaxInclusive": true,
    "invoiceNo": nextInvoice,
  }
};
    print("json: $jsonData");
    return jsonEncode(jsonData);
    } catch (e) {
      Get.snackbar(
        "Error Message",
        "$e",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.red,
        icon:const Icon(Icons.error),
        shouldIconPulse: true
      );
    }
    
  }
  /// Function to generate `receiptTaxes` dynamically
List<Map<String, dynamic>> generateReceiptTaxes(List<dynamic> receiptItems) {
  Map<int, Map<String, dynamic>> taxGroups = {}; // Store tax summaries

  for (var item in receiptItems) {
    int taxID = item["taxID"];
    double taxPercent = item["taxPercent"];
    double total = item["total"];

    if (!taxGroups.containsKey(taxID)) {
      taxGroups[taxID] = {
        "taxID": taxID,
        "taxPercent": taxPercent.toStringAsFixed(2),
        "taxCode": item["taxCode"],
        "taxAmount": 0.0,
        "salesAmountWithTax": 0.0
      };
    }

    // Calculate tax amount
    double taxAmount = (total * taxPercent) / 100 ;
    taxGroups[taxID]!["taxAmount"] += taxAmount;
    taxGroups[taxID]!["salesAmountWithTax"] += total;
  }

  // Convert map to list and round values
  return taxGroups.values.map((tax) {
    return {
      "taxID": tax["taxID"],
      "taxPercent": tax["taxPercent"],
      "taxCode": tax["taxCode"],
      "taxAmount": tax["taxAmount"].toStringAsFixed(2),
      "salesAmountWithTax": tax["salesAmountWithTax"].toStringAsFixed(2)
    };
  }).toList();
}

/// Function to generate `receiptTaxes` concatenation
String generateTaxSummary(List<dynamic> receiptItems) {
  Map<int, Map<String, dynamic>> taxGroups = {}; // Store tax summaries

  for (var item in receiptItems) {
    int taxID = item["taxID"];
    double taxPercent = item["taxPercent"];
    double total = item["total"];
    String taxCode = item["taxCode"];

    if (!taxGroups.containsKey(taxID)) {
      taxGroups[taxID] = {
        "taxCode": taxCode,
        "taxPercent": taxPercent.toStringAsFixed(2),
        "taxAmount": 0.0,
        "salesAmountWithTax": 0.0
      };
    }

    // Calculate tax amount
    double taxAmount = (total * taxPercent) / (100 + taxPercent);
    taxGroups[taxID]!["taxAmount"] += taxAmount;
    taxGroups[taxID]!["salesAmountWithTax"] += total;
  }

  // Convert tax groups to a sorted list (optional: sort by taxCode)
  List<Map<String, dynamic>> sortedTaxes = taxGroups.values.toList()
    ..sort((a, b) => a["taxCode"].compareTo(b["taxCode"]));

  // Concatenate tax details in the required order
  return sortedTaxes.map((tax) {
    return "${tax["taxCode"]}${tax["taxPercent"]}${tax["taxAmount"].toStringAsFixed(2)}${tax["salesAmountWithTax"].toStringAsFixed(2)}";
  }).join("");
}

/// Function to generate the final concatenated receipt string
String generateReceiptString({
  required int deviceID,
  required String receiptType,
  required String receiptCurrency,
  required int receiptGlobalNo,
  required DateTime receiptDate,
  required double receiptTotal,
  required List<dynamic> receiptItems,
}) {
  String formattedDate = receiptDate.toIso8601String();
  String formattedTotal = receiptTotal.toStringAsFixed(2);
  String receiptTaxes = generateTaxSummary(receiptItems);

  return "$deviceID$receiptType$receiptCurrency$receiptGlobalNo$formattedDate$formattedTotal$receiptTaxes";
}
  /// Generate SHA-256 Hash
  generateHash() async {
    String receiptString = generateReceiptString(
    deviceID: 21659,
    receiptType: "FISCALINVOICE",
    receiptCurrency: "ZWL",
    receiptGlobalNo: 2,
    receiptDate: DateTime.now(),
    receiptTotal: 945.00,
    receiptItems: receiptItems,
  );
  print("Concatenated Receipt String: $receiptString");

    var bytes = utf8.encode(receiptString);
    var digest = sha256.convert(bytes);
    final hash = base64.encode(digest.bytes);
    print(hash);
    return hash;
  }

  // Future<String> initializePrivateKey() async {
  //   privateKey = await readPrivateKeyFromStorage();
  //   return privateKey;

  // }

  // Future<String> readPrivateKeyFromStorage() async {
  // await Future.delayed(Duration(seconds: 5));
  // bool hasPermission = await requestStoragePermission();
  // final directory = await getApplicationDocumentsDirectory();
  // String privateKeyPath = "/storage/emulated/0/Pulse/Configurations/testwelleast_T_private.pem";
  // File file = File(privateKeyPath);
  // if (!hasPermission) {
  //   print("Permission denied. Cannot access external storage.");
  // }
  // if (!file.existsSync()) {
  //   print("Private Key file not found at: $privateKeyPath");
  // }

  // print("Private Key file exists and is accessible!");
  // Uint8List privateKeyBytes = await file.readAsBytes();
  // String privateKeyPem = utf8.decode(privateKeyBytes);
  // //return await file.readAsString()
  // final logger = Logger();
  //     logger.d(privateKeyPem);
  // return privateKeyPem;
  // }

  
Uint8List signHash(String hash, RSAPrivateKey privateKey) {
  var signer = Signer('SHA-256/RSA')
    ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  return signer.generateSignature(Uint8List.fromList(base64Decode(hash))) as Uint8List;
}

String generateDeviceSignature(String hash, RSAPrivateKey privateKey) {
  Uint8List signatureBytes = signHash(hash, privateKey);
  return base64Encode(signatureBytes);
}

  


//   Future<String> signHash(String hash) async {
//   try {
//     String privateKeyPem = await initializePrivateKey();

//   final logger = Logger();
//   logger.d(privateKeyPem);
//   logger.d(hash);
//   // Convert Base64-encoded hash to Uint8List
//   Uint8List hashBytes = base64Decode(hash);

//   // Parse the private key
//   if (privateKeyPem.isEmpty) {
//     throw Exception("Private key is empty or invalid.");
//   }
//   if(!privateKeyPem.contains("END RSA PRIVATE KEY")){
//     logger.w("Key Incomplete");
//   }
//   else
//   {logger.d("key complete");}
    
//   RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);

//   // Create the signer
//   RSASigner signer = RSASigner(SHA256Digest(), "0609608648016503040201");

//   signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

//   // Generate the signature
//   RSASignature signature = signer.generateSignature(hashBytes);

//   return base64Encode(signature.bytes);
//   } catch (e) {
//     return "Error: $e";
//   }
// }


  
  
  
  // void addReceipt(int receiptCounter) async{
  //   final db = DatabaseHelper();
  //   try {
  //     db.addReceipt(SubmittedReceipt(
  //       receiptCounter: json["receiptCounter"],
  //       fiscalDayNo: json["FiscalDayNo"],
  //       invoiceNo: await dbHelper.getNextInvoiceId(),
  //       receiptId: json["receiptID"],
  //       receiptType: json["receiptType"],
  //       receiptCurrency: json["receiptCurrency"],
  //       moneyType: json["moneyType"],
  //       receiptDate: DateTime.parse(json["receiptDate"]),
  //       receiptTime: json["receiptTime"],
  //       receiptTotal: totalAmount,
  //       taxCode: "C",
  //       taxPercent: "15.00",
  //       taxAmount: taxAmount,
  //       salesAmountwithTax:salesAmountwithTax,
  //       receiptHash: generateHash(jsonEncode(receiptItems)),
  //       receiptJsonbody: generateFiscalJSON(),
  //       statustoFdms: json["StatustoFDMS"],
  //       qrurl: json["qrurl"],
  //       receiptServerSignature: json["receiptServerSignature"],
  //       submitReceiptServerresponseJson: json["submitReceiptServerresponseJSON"],
  //       total15Vat: json["Total15VAT"],
  //       totalNonVat: json["TotalNonVAT"],
  //       totalExempt: json["TotalExempt"],
  //       totalWt: json["TotalWT"],
  //     )); 
  //   } catch (e) {
      
  //   }
  // }
  
  void encodeSignatures (){
    String Signature = "ONF7PnfI6o5NAfPycPxEOMAz2uW8uOAyKGZI45Zpx73CzupMgiKPC3fFvkbu2tEYd6okcBkcoPHrlr2301r+M+BLgwbxEzJSHFCBK4zqnwua87J9A9mukQ7lFyGeObvHyismEFhnn5+2XB8ljOHjyw0dIu18booOP/OT/QLEJr6dlH27aUYmSAKTWBJpGb5fMo/7p+uH+o/ablosxHuC0k6WyxT62Axm8sUVNhfrCUny18Z+H93gOuGF7sEPv/HFe+4Q+TwK9ziOoSI/0BnlimG0aomDb9Go3F5AhIm2jNPlTImrMzHJlp2MMXfzFAG9+kCNTi0ryIAHTHAJRjuEyQ\u003d\u003d";
    String hash= "5awS4i+L++uom200XGBpvB6cECSyu+jr0vHbsYD2P2o\u003d" ;
    encodedSignature = base64Encode(utf8.encode(Signature));
    encodedHash = base64Encode(utf8.encode(hash));
  }
  
  Map<String , dynamic> jsonDatatest = {"receipt":{"receiptLines":[{"receiptLineNo":"1","receiptLineHSCode":"99001000","receiptLinePrice":"434.78","taxID":3,"taxPercent":"15.00","receiptLineType":"Sale","receiptLineQuantity":"1.0","taxCode":"C","receiptLineTotal":"434.78","receiptLineName":"RENTAL JANUARY 2025 "}],"receiptType":"FISCALINVOICE","receiptGlobalNo":6,"receiptCurrency":"USD","receiptPrintForm":"InvoiceA4","receiptDate":"2025-01-31T17:18:37","receiptPayments":[{"moneyTypeCode":"Cash","paymentAmount":"434.78"}],"receiptCounter":5,"receiptTaxes":[{"taxID":"3","taxPercent":"15.00","taxCode":"C","taxAmount":"56.71","SalesAmountwithTax":434.78}],"receiptDeviceSignature":{"signature":"","hash": ""},"buyerData":{"VATNumber":"123456789","buyerTradeName":"SAT ","buyerTIN":"0000000000","buyerRegisterName":"SAT "},"receiptTotal":"434.78","receiptLinesTaxInclusive":true,"invoiceNo":"00000390"}};
  Future<void> submitReceipt() async {
  String apiEndpointSubmitReceipt =
      "https://fdmsapitest.zimra.co.zw/Device/v1/21659/SubmitReceipt";
  const String deviceModelName = "Server";
  const String deviceModelVersion = "v1";  

  SSLContextProvider sslContextProvider = SSLContextProvider();
  SecurityContext securityContext = await sslContextProvider.createSSLContext();

  // Call the Ping function
  final String response = await SubmitReceipts.submitReceipts(
    apiEndpointSubmitReceipt: apiEndpointSubmitReceipt,
    deviceModelName: deviceModelName,
    deviceModelVersion: deviceModelVersion,
    securityContext: securityContext,
    receiptjsonBody: jsonEncode(jsonDatatest),
  );

  if(response.isNotEmpty){
    receiptItems.clear();
    clearCart();
    paidController.clear();
    selectedCustomer.clear();
    selectedPayMethod.clear();
  }

  //print("Response: \n$response");
  Get.snackbar(
      "Zimra Response", "$response",
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      backgroundColor: Colors.green,
      icon: const Icon(Icons.message, color: Colors.white),
    );
  print(response);
}
  //=================FUNCTIONS============================//
  //======================================================//
  // Toggle barcode scanner
  // void toggleBarcodeScanner() {
  //   setState(() {
  //     isBarcodeEnabled = !isBarcodeEnabled;
  //   });

  //   if (isBarcodeEnabled) {
  //     startBarcodeScan();
  //   }
  // }

  // Start barcode scanning
  // Future<void> startBarcodeScan() async {
  //   while (isBarcodeEnabled) {
  //     try {
  //       String barcode = await FlutterBarcodeScanner.scanBarcode(
  //         "#ff6666", // Line color for the scanner
  //         "Cancel", // Text for the cancel button
  //         true, // Show the flash icon
  //         ScanMode.BARCODE, // Scan mode (BARCODE or QR)
  //       );

  //       if (barcode != "-1") {
  //         await addToCartBarcode(barcode);
  //       } else {
  //         // If canceled, stop scanning
  //         break;
  //       }
  //     } catch (e) {
  //       print("Error while scanning: $e");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error while scanning barcode.")),
  //       );
  //       break;
  //     }
  //   }
  // }

// Add product to cart
  // Future<void> addToCartBarcode(String barcode) async {
  //   final product = await dbHelper.getProductByBarcode(barcode);

  //   if (product != null) {
  //     setState(() {
  //       int existingIndex = cartItems.indexWhere((item) => item['barcode'] == barcode);

  //       if (existingIndex != -1) {
  //         cartItems[existingIndex]['quantity']++;
  //       } else {
  //         cartItems.add({
  //           ...product,
  //           'quantity': 1,
  //         });
  //       }
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Product not found!')),
  //     );
  //   }
  // }


  void completeSale() async {
    try {
      final double totalAmount = calculateTotalPrice();
    final double totalTax = calculateTotalTax();
    final double indiTax = calculateIndividualtax();
    final int customerID;
    
    if(selectedCustomer.isEmpty){
      customerID = 999999;
      //= selectedCustomer[0]['customerID']
      await dbHelper.saveSale(cartItems, totalAmount, totalTax , indiTax, customerID );
      for (var item in cartItems){
      int sellQty = item['sellqty'];
      int productid = item['productid'];
      final product = await dbHelper.getProductById(productid);
      setState(() {
        productOnSale = product;
      });
      int productOnSaleQty = productOnSale[0]['stockQty'];
      int remainingStock = productOnSaleQty - sellQty;
      dbHelper.updateProductStockQty(productid, remainingStock);
    }
    }
    else{
      customerID = selectedCustomer[0]['customerID'];
      await dbHelper.saveSale(cartItems, totalAmount, totalTax , indiTax, customerID );
      for (var item in cartItems){
      int sellQty = item['sellqty'];
      int productid = item['productid'];
      final product = await dbHelper.getProductById(productid);
      setState(() {
        productOnSale = product;
      });
      int productOnSaleQty = productOnSale[0]['stockQty'];
      int remainingStock = productOnSaleQty - sellQty;
      dbHelper.updateProductStockQty(productid, remainingStock);
    }
    }
    Get.snackbar(
      'Fiscalizing',
      'Processing',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      showProgressIndicator: true,
    );

    Get.snackbar(
      'Succes',
      'Sales Done',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
    );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Sale Not Done: $e",
        icon: Icon(Icons.error),
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
    // Clear the cart
    // Notify user
    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sale completed!")))
  }

  void clearCart(){
    setState(() {
      cartItems.clear();
    });
  }

  void searchProducts(String query) async{
    final results = await dbHelper.searchProducts(query);
    setState(() {
      searchResults = results;
    });
  }

  void searchCustomerDetails(String query) async{
    final customerSearchResult = await dbHelper.searchCustomer(query);
    setState(() {
      customerDetails = customerSearchResult;
    });
  }

  Future<void> fetchPayMethods() async {
    List<Map<String, dynamic>> data = await dbHelper.getPaymentMethods();
    setState(() {
      payMethods = data;
    });
  }

  Future<void> fetchDefaultCurrency() async {
    try {
      String? currency = await dbHelper.getDefaultCurrency();
      setState(() {
        defaultCurrency = currency ?? 'N/A'; // Display 'N/A' if no default currency is found
      });
    } catch (e) {
      print('Error fetching default currency: $e');
      setState(() {
        defaultCurrency = 'Error';
      });
    }

  }

  Future<void> fetchDefaultRate() async {
    try {
      double? rate = await dbHelper.getDefaultRate();
      setState(() {
        defaultRate = rate ?? 1.0; // Default to 0.0 if no rate is found
      });
    } catch (e) {
      print('Error fetching default rate: $e');
      setState(() {
        defaultRate = null; // Handle error by setting rate to null
      });
    }
  }

  Future<void> fetchDefaultPayMethod() async {
  int defaultTag = 1;
  try {
    List<Map<String, dynamic>> data = await dbHelper.getDefaultPayMethod(defaultTag);
    if (data.isNotEmpty) {
      defaultPayMethod = data;
      print('Default payment method fetched: $defaultPayMethod');
    } else {
      print('No default payment method found for defaultTag: $defaultTag');
      defaultPayMethod = [];
    }
  } catch (e) {
    print('Error fetching default payment method: $e');
    defaultPayMethod = []; // Optional: Handle this scenario based on your application logic
  }
}


  void addToCustomer(Map<String , dynamic> customer){
    selectedCustomer.add(customer);
    Get.snackbar(
      "Success",
      "Customer Added",
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP
    );
    Navigator.pop(context);
  }

  void addToPayments(Map<String , dynamic> payMethod){
    selectedPayMethod.add(payMethod);

    Get.snackbar(
      "Success",
      "Customer Added",
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP
    );
    Navigator.pop(context);
  }

  String returnCurrency() {
    if (selectedPayMethod.isNotEmpty) {
      String selectedCurrency = selectedPayMethod[0]['currency'];
      print(selectedCurrency);
      return selectedCurrency;
      
    } else {
      return defaultCurrency ?? 'N/A';
    }
  }

  void addToCart(Map<String, dynamic> product) {
    //double qty = 1;
    int stockQty = product['stockQty'];
    if (stockQty > 0){
      setState(() {

      int index = cartItems.indexWhere((item) => item['productid']==product['productid']);
      if(index != -1){
        cartItems[index]['sellqty'] +=1;
      }else{
        Map<String, dynamic> updatedProduct = {...product};
        updatedProduct['sellqty'] = 1;
        cartItems.add(updatedProduct);
      }
    });
    }
    else{
      Get.snackbar(
        "No Stock",
        "Product is now out of stock",
        colorText: Colors.black,
        backgroundColor: Colors.amber,
        icon:const Icon(Icons.error)
      );
    }
    
  }

  double calculateTotalTax() {
    double totalTax = 0.0;
    
    for (var item in cartItems) {
      final taxType = item['tax']; // e.g., 'vat', 'zero', 'ex'
      final sellingPrice = item['sellingPrice'];
      final quantity = item['sellqty'];

      // Determine the applicable tax rate
      double taxRate = 0.0;
      if (taxType == 'vat') {
        taxRate = 0.15; // 15% VAT
      } else if (taxType == 'zero' || taxType == 'ex') {
        taxRate = 0.0; // Zero-rated or exempted
      }

      if(selectedPayMethod.isEmpty){
        totalTax += sellingPrice * quantity*taxRate;
      }
      else{
        double rate  = selectedPayMethod[0]['rate'];
        totalTax += sellingPrice * quantity * taxRate *rate;
      }
      // Calculate the tax for this item
    }
    return totalTax;
  }

  double calculateIndividualtax(){
    double indiTax  = 0 ;
    for (var item in cartItems) {
      final taxType = item['tax']; // e.g., 'vat', 'zero', 'ex'
      final sellingPrice = item['sellingPrice'];
      final quantity = item['sellqty'];

      // Determine the applicable tax rate
      double taxRate = 0.0;
      if (taxType == 'vat') {
        taxRate = 0.15; // 15% VAT
      } else if (taxType == 'zero' || taxType == 'ex') {
        taxRate = 0.0; // Zero-rated or exempted
      }

      // Calculate the tax for this item
      indiTax = sellingPrice * quantity * taxRate;
    }
    return indiTax;
  }

 

  double calculateTotalPrice() {

    return cartItems.fold(0.0, (total, item) {
      final double sellingPrice = item['sellingPrice'] ?? 0.0; // Default to 0.0 if null
      final int sellQty = item['sellqty'] ?? 1.0; // Default to 1.0 if null
      if(selectedPayMethod.isEmpty){
        return total + (sellingPrice * sellQty);
      }else{
        double rate  = selectedPayMethod[0]['rate'];
        return total + (sellingPrice * sellQty * rate);
      }
      
    });
  }

  ///=====CUSTOMER DETAILS=====//////////
  //////////////////////////////////////
  addCustomerDetails(){
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
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Existing?"),
                        SizedBox(height: 10,),
                        Expanded(
                          child: TextField(
                            controller: searchCustomer,
                            onChanged: searchCustomerDetails,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color:Colors.grey.shade600 ),
                              filled: true,
                              fillColor: Colors.grey.shade300,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                              )
                            ),
                            
                          )
                        ),
                        IconButton(
                          onPressed: (){
                            searchCustomerDetails(searchCustomer.text);
                            setState(() {
                              isActve = false;
                            });
                          },
                          icon: Icon(Icons.person_search_rounded)
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                        color:const Color.fromARGB(255, 14, 19, 29),
                      ),
                      child: ListView.builder(
                        itemCount: customerDetails.length,
                        itemBuilder: (context , index){
                          final customer = customerDetails[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0), 
                              color: Colors.white, 
                            ),
                            child: ListTile(
                              title: Text(customer['tradeName']),
                              subtitle: Text("Price: \$${customer['tinNumber']}"),
                              trailing: IconButton(onPressed: ()=>addToCustomer(customer), icon:const Icon(Icons.add_circle_outline_sharp)),
                            ),
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                          labelText: 'Trade Name',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
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
                      controller: tinController,
                      decoration: InputDecoration(
                          labelText: 'TIN Number',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "TIN Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: vatController,
                      decoration: InputDecoration(
                          labelText: 'VAT Number',
                          enabled: isActve,
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
                            return "VAT Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
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
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
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
                          if(formKey.currentState!.validate()){
                            final db = DatabaseHelper();
                            await db.addCustomer(Customer(
                              tradeName: customerNameController.text,
                              tinNumber: int.parse(tinController.text),
                              vatNumber: int.parse(vatController.text),
                              address: addressController.text,
                              email: emailController.text
                            ));
                            setState(() {
                              selectedCustomer.add({
                                'tradeName': customerNameController.text,
                                'tinNumber': tinController.text,
                                'vatNumber': vatController.text,
                                'address': addressController.text,
                                'email': emailController.text,
                              });
                            });
                            
                            Navigator.pop(context);
                            Get.snackbar(
                              'Success',
                              'Customer Details Saved',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDark,
                          padding:const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Save Customer',
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
  
 

  ///=====PAYMENT METHODS=====//////////
  //////////////////////////////////////
  addpaymethod(){
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
                        const Center(child: const Text("Payment Methods" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 15,),
                    
                    SizedBox(height: 10,),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                        color:const Color.fromARGB(255, 14, 19, 29),
                      ),
                      child: ListView.builder(
                        itemCount: payMethods.length,
                        itemBuilder: (context , index){
                          final payMethod = payMethods[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0), 
                              color: Colors.white, 
                            ),
                            child: ListTile(
                              title: Text(payMethod['description']),
                              subtitle: Text("Rate: ${payMethod['rate']}"),
                              trailing: IconButton(onPressed: (){
                                addToPayments(payMethod);
                                returnCurrency();
                              }, icon:const Icon(Icons.add_circle_outline_sharp)),
                            ),
                          );
                        }
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
  
  //=================END OF FUNCTIONS============================//a
  //======================================================//
  

  @override  Widget build(BuildContext context) {
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
              CustomField(
                controller: controller,
                onChanged: searchProducts,
              ),
              GestureDetector(
                onTap: ()=> searchProducts(controller.text),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding:const  EdgeInsets.symmetric(horizontal: 5.0 , vertical: 10.0) ,
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                    color:const Color.fromARGB(255, 14, 19, 29),
                  ),
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context , index){
                      final product = searchResults[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0), 
                          color: Colors.white, 
                        ),
                        child: ListTile(
                          title: Text(product['productName']),
                          subtitle: Text("Price: \$${product['sellingPrice']}"),
                          trailing: IconButton(onPressed: ()=>addToCart(product), icon:const Icon(Icons.add_circle_outline_sharp)),
                        ),
                      );
                    }
                    ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isBarcodeEnabled?  Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        //toggleBarcodeScanner;
                        if(isBarcodeEnabled){
                          setState(() {
                            isBarcodeEnabled = false;
                          });
                        }else{
                          setState(() {
                            isBarcodeEnabled = true;
                          });
                        }
                      },
                      child: Center(
                        child: isBarcodeEnabled? const Icon(Icons.barcode_reader , size: 25, color: Colors.white) : const Icon(Icons.barcode_reader , size: 25, color: Color.fromARGB(255, 14, 19, 29),) ,
                      )),
                    ),
                    //////////Button
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        addCustomerDetails();
                      },
                      child: const Center(
                        child: Icon(Icons.person , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                      )),
                    ),
                    //////////Button
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        try {
                          fetchPayMethods();
                          addpaymethod();
                        } catch (e) {
                          Get.snackbar("Error","$e", icon: Icon(Icons.error ,) ,colorText: Colors.white, backgroundColor: Colors.red);
                        }
                        
                      },
                      child: const Center(
                        child: Icon(Icons.monetization_on , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                      )),
                    ),
                    //////////Button
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        
                      },
                      child: const Center(
                        child: Icon(Icons.discount , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                      )),
                    ),
                    //////////Button
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        
                      },
                      child: const Center(
                        child: Icon(Icons.save , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                      )),
                    ),
                    //////////Button
                    Container(
                      height: 50 ,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
        
                          )
                        ] 
                      ),
                      child: TextButton(onPressed: (){
                        
                      },
                      child: const Center(
                        child: Icon(Icons.scale , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                      )),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 20,),
                const Text(
                  "Cart",
                  style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                    color: const Color.fromARGB(255, 14, 19, 29),
                  ),
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context , index){
                      final product = cartItems[index];
                      return Dismissible(
                        key: Key(product['productid'].toString()),
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Swipe to the right to delete
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Item'),
                                content: const Text('Are you sure you want to remove this item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            );
                            return confirm;
                          } else {
                              // Swipe to the left to add or subtract
                              //_showQuantityAdjustmentDialog(product);
                            return false; // Prevent dismissal
                          }
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0), 
                            color: Colors.white, 
                          ),
                          child: ListTile(
                              title: Text(product['productName']),
                              subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toUpperCase()}"),
                              trailing: IconButton(onPressed: (){}, icon:const Icon(Icons.minimize_outlined)),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 14, 19, 29),
                                  borderRadius: BorderRadius.circular(50.0)
                                ),
                                child:  Center(
                                  child:  Text(
                                    product['sellqty'].toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                ),
        
                              ),
                            ),
                        ),
                      );
                    }
                    ),
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 19, 29),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(defaultCurrency != null && selectedPayMethod.isEmpty ? '$defaultCurrency' : returnCurrency() , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                              Text(":\$${calculateTotalPrice().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                            ],
                          ),
                          const SizedBox(width: 20),
                          //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                          Text("QTY: ${cartItems.length}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                          const SizedBox(width: 20),
                          //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                          Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                          //Text("\$${calculateTotalTax().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            )
          ),
      ),
        bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 14, 19, 29),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){

                },
                icon: const Column(
                  children: [
                    Icon(Icons.home, color: Colors.white,),
                    Text(
                        "Home",
                        style: TextStyle(fontSize: 10,color: Colors.white),
                    )
                  ],
                ),
            ),
            IconButton(
              onPressed: (){
                //Navigator.pushReplacement(
                  //context,
                  //MaterialPageRoute(builder: (context) => MyAccount()),
                //);
              },
              icon: const Column(
                children: [
                  Icon(Icons.list_alt, color: Colors.white),
                  Text(
                    "Products",
                    style: TextStyle(fontSize: 10  ,color: Colors.white),
                  )
                ],
              ),
            ),
            FloatingActionButton(
                onPressed: () async {
                  if(cartItems.isEmpty){
                    await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Empty Cart'),
                              content: const Text('You did not select any product to complate the sale'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Get Back'),
                                ),
                              ],
                            ),
                          );
                  }
                  else{
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
                              key: paidKey,
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
                                        const Text("Customer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),),
                                      ],
                                    ),
                                    selectedCustomer.isEmpty?
                                    const Text("Customer: Cash" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),):
                                    Text("Customer: ${ selectedCustomer[0]['tradeName']}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    const SizedBox(width: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(defaultCurrency != null && selectedPayMethod.isEmpty ? '$defaultCurrency' : returnCurrency() , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20),),
                                          Text(":\$${calculateTotalPrice().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.bold , fontSize: 20),),
                                        ],
                                    ),
                                    const SizedBox(width: 20),
                                    //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                    Text("Items: ${cartItems.length}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    const SizedBox(width: 20),
                                    //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                    Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: kDark,
                                      ),
                                      child: ListView.builder(
                                        itemCount: cartItems.length,
                                        itemBuilder: (context , index){
                                          final product = cartItems[index];
                                          return ListTile(
                                            title: Text(product['productName'] , style: const TextStyle(color: Colors.white),),
                                            subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toUpperCase()}", style: const TextStyle(color: Colors.white),),
                                            leading: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(50.0)
                                              ),
                                              child:  Center(
                                                child:  Text(
                                                  product['sellqty'].toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDark),
                                                ),
                                              ),
                              
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    const SizedBox(height: 30,),
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Paid", style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*'), // Allows only digits and a single decimal point
                                              ),
                                            ],
                                            controller: paidController,
                                            decoration: InputDecoration(
                                              labelText: 'Amount Paid',
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
                                                return "Amount Required";
                                              }return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 40,),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          try {
                                            // Check if the text input is empty
                                            if (paidController.text.isEmpty) {
                                              Get.snackbar(
                                                "Alert",
                                                "Sales cannot complete without amount paid",
                                                icon: Icon(Icons.sd_card_alert),
                                                colorText: Colors.black,
                                                backgroundColor: Colors.amber,
                                              );
                                              return; // Exit the function
                                            }

                                            double paid = double.tryParse(paidController.text) ?? 0.0;
                                            double price = double.parse(calculateTotalPrice().toString());

                                            // Validate the parsed values
                                            if (paid <= 0) {
                                              Get.snackbar(
                                                "Error",
                                                "Invalid amount paid. Please enter a valid number.",
                                                icon: Icon(Icons.error),
                                                colorText: Colors.white,
                                                backgroundColor: Colors.red,
                                              );
                                              return; // Exit the function
                                            }

                                            if (paid < price) {
                                              Get.snackbar(
                                                "Error",
                                                "Amount Paid Is Not Sufficient",
                                                icon: Icon(Icons.error),
                                                colorText: Colors.white,
                                                backgroundColor: Colors.red,
                                              );
                                              return; // Exit the function
                                            }
                                            // Complete the sale if all validations pass
                                            addItem();
                                            generateFiscalJSON();
                                            generateHash();
                                            submitReceipt();
                                            completeSale();
                                            Navigator.pop(context);
                                            } catch (e) {
                                              Get.snackbar(
                                                "Error",
                                                "An error occurred: $e",
                                                icon: Icon(Icons.error),
                                                colorText: Colors.white,
                                                backgroundColor: Colors.red,
                                                snackPosition: SnackPosition.TOP,
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
                                          'Save Sale',
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
                  
                },
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.done_outline_rounded,
                  color: Colors.white,
                ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => MyLoans()),
                //);
              },
              icon: const Column(
                children: [
                  Icon(Icons.summarize, color: Colors.white),
                  Text(
                    "Reporting",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clearing Cart!!'),
                              content: const Text('Are you sure you want to cancel the sale'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Get Back'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setState(() {
                                      cartItems.clear();
                                    });
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => Profile()),
               // );
              },
              icon: const Column(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  Text(
                    "Cancel",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ); 
  }
}