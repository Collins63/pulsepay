import 'dart:convert';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
import 'package:pulsepay/fiscalization/ping.dart';
import 'package:pulsepay/fiscalization/receiptResponse.dart';
import 'package:pulsepay/fiscalization/sslContextualization.dart';
import 'package:pulsepay/fiscalization/submitReceipts.dart';
import 'package:pulsepay/main.dart';
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
  List<Map<String, dynamic>> products = [];
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
  String? signature64 ;
   String? signatureMD5 ;
  

  Future<bool> requestStoragePermission() async {
  if (await Permission.storage.isGranted) {
    return true;
  }
  
  var status = await Permission.storage.request();
  return status.isGranted;
}

  addItem() async{
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
  Future<RSAPrivateKey?> loadPrivateKeyFromP12(String filePath , String password) async{
    bool hashPermission = await requestStoragePermission();
    if(!hashPermission){
      print("Cannot access file...not permitted");
      return null;
    }

    //Load file\
    File p12File = File(filePath);
    if(!p12File.existsSync()){
      print("Keystore file not found");
      return null;
    }
    print("private keyy found");

    //Uint8List p12Bytes = await p12File.readAsBytes();
    Uint8List p12Bytes = await p12File.openRead().fold<Uint8List>(
  Uint8List(0),
  (buffer, chunk) => Uint8List.fromList([...buffer, ...chunk])
);
    //print(p12Bytes);
    var logger = Logger();
    logger.d("p12Bytes: $p12Bytes");
    List<String> pemList = Pkcs12Utils.parsePkcs12(p12Bytes , password: password);
    print("pem list found");
    print(pemList);
    if(pemList.isEmpty){
      print("No private key found in p12 file");
    }
    String privateKeyPem = pemList.firstWhere(
      (pem) => pem.contains("BEGIN PRIVATE KEY"),
      orElse: ()=> "",
    );
    print("private key pem found");
    if(privateKeyPem.isEmpty){
      print("NO RSA privatekey found");
    }
    return CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
  }

  Uint8List signHash(String hash, RSAPrivateKey privateKey) {
  var signer = Signer('SHA-256/RSA')
    ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

  return signer.generateSignature(Uint8List.fromList(base64Decode(hash))) as Uint8List;
}

String generateDeviceSignature(String hash, RSAPrivateKey privateKey) {
  Uint8List signatureBytes = signHash(hash, privateKey);
  return base64Encode(signatureBytes);
}
String computeMD5(Uint8List signatureBytes) {
  var md5Hash = md5.convert(signatureBytes);
  return md5Hash.toString();
}
Future<Map<String, String>?> generateRSASignature(String hash, String p12FilePath, String password) async {
  print("Entered generate signatyre");
  RSAPrivateKey? privateKey = await loadPrivateKeyFromP12(p12FilePath, password);
  print("Got private key");
  if (privateKey == null) {
    print("❌ Unable to sign data because private key could not be loaded.");
    return null;
  }else{
    print("Key loaded");
  }
  

  // Generate SHA-256 Hash
  hash = await generateHash();
  print("✅ Generated Hash (Base64): $hash");
  Uint8List hashBytes = base64Decode(hash);
  String stringHasybt = hashBytes.toString();

  // Sign the hash using RSA
  Uint8List signatureBytes = signHash(stringHasybt, privateKey);

  // Convert to Base64 and compute MD5 hash
  String base64Signature = base64Encode(signatureBytes);
  String md5Signature = computeMD5(signatureBytes);

  return {
    "signatureHex": md5Signature,
    "signatureBase64": base64Signature,
  };
}

  void signKotlin() async {
    String filePath = "/storage/emulated/0/Pulse/Configurations/testwelleast_T_certificate.p12";
    String password = "testwelleast123";
    String data = await generateHash();
    String signedData = await signData(filePath, password, data);
    print("Signed Data: $signedData");  
  }
  /// Generate JSON after sale
  Future<String> generateFiscalJSON() async {
  try {
    print("Entered generateFiscalJSON");

    String filePath = "/storage/emulated/0/Pulse/Configurations/testwelleast_T_certificate.p12";
    String password = "testwelleast123";

    // Ensure signing does not fail
    String signedData;
    try {
      String data = await generateHash();
      signedData = await signData(filePath, password, data);
    } catch (e) {
      Get.snackbar("Signing Error", "$e", snackPosition: SnackPosition.TOP);
      return "{}";
    }

    print("Signed Data: $signedData");

    if (receiptItems.isEmpty) {
      print("Receipt items are empty, returning empty JSON.");
      return "{}";
    }

    String hash = await generateHash();
    print("Hash generated successfully");

    int nextInvoice = await dbHelper.getNextInvoiceId();

    String saleCurrency = selectedPayMethod.isEmpty ? defaultCurrency.toString() : returnCurrency();

    // Ensure tax calculation does not fail
    List<Map<String, dynamic>> taxes = [];
    try {
      taxes = generateReceiptTaxes(receiptItems);
    } catch (e) {
      Get.snackbar("Tax Calculation Error", "$e", snackPosition: SnackPosition.TOP);
      return "{}";
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);


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
        "receiptGlobalNo": 3,
        "receiptCurrency": saleCurrency,
        "receiptPrintForm": "InvoiceA4",
        "receiptDate": formattedDate ,
        "receiptPayments": [
          {"moneyTypeCode": "Cash", "paymentAmount": totalAmount.toStringAsFixed(2)}
        ],
        "receiptCounter": 1,
        "receiptTaxes": taxes,
        "receiptDeviceSignature": {
          "signature": signedData,
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
        "invoiceNo": nextInvoice.toString(),
      }
    };

    // Ensure JSON encoding does not fail
    final jsonString;
    try {
      jsonString = jsonEncode(jsonData);
    } catch (e) {
      Get.snackbar("JSON Encoding Error", "$e", snackPosition: SnackPosition.TOP);
      return "{}";
    }
    File file = File("/storage/emulated/0/Pulse/Configurations/jsonFile.txt");
    await file.writeAsString(jsonString);
    print("Generated JSON: $jsonString");
    return jsonString;

  } catch (e) {
    Get.snackbar(
      "Error Message",
      "$e",
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      backgroundColor: Colors.red,
      icon: const Icon(Icons.error),
      shouldIconPulse: true
    );
    return "{}"; // Ensure the function always returns something
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
  Future<String> ping() async {
  String apiEndpointPing =
      "https://fdmsapitest.zimra.co.zw/Device/v1/21659/Ping";
  const String deviceModelName = "Server";
  const String deviceModelVersion = "v1"; 

  SSLContextProvider sslContextProvider = SSLContextProvider();
  SecurityContext securityContext = await sslContextProvider.createSSLContext();

  // Call the Ping function
  final String response = await PingService.ping(
    apiEndpointPing: apiEndpointPing,
    deviceModelName: deviceModelName,
    deviceModelVersion: deviceModelVersion,
    securityContext: securityContext,
  );

  //print("Response: \n$response");
  Get.snackbar(
      "Zimra Response", "$response",
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      backgroundColor: Colors.green,
      icon: const Icon(Icons.message, color: Colors.white),
    );
  
    return response;
}
  Map<String , dynamic> jsonDatatest = {"receipt":{"receiptLines":[{"receiptLineNo":"1","receiptLineHSCode":"99001000","receiptLinePrice":"434.78","taxID":3,"taxPercent":"15.00","receiptLineType":"Sale","receiptLineQuantity":"1.0","taxCode":"C","receiptLineTotal":"434.78","receiptLineName":"RENTAL JANUARY 2025 "}],"receiptType":"FISCALINVOICE","receiptGlobalNo":6,"receiptCurrency":"USD","receiptPrintForm":"InvoiceA4","receiptDate":"2025-01-31T17:18:37","receiptPayments":[{"moneyTypeCode":"Cash","paymentAmount":"434.78"}],"receiptCounter":5,"receiptTaxes":[{"taxID":"3","taxPercent":"15.00","taxCode":"C","taxAmount":"56.71","SalesAmountwithTax":434.78}],"receiptDeviceSignature":{"signature":"","hash": ""},"buyerData":{"VATNumber":"123456789","buyerTradeName":"SAT ","buyerTIN":"0000000000","buyerRegisterName":"SAT "},"receiptTotal":"434.78","receiptLinesTaxInclusive":true,"invoiceNo":"00000390"}};

  Future<void> submitReceipt() async {
    String jsonString  = await generateFiscalJSON();
    final receiptJson = jsonEncode(jsonString);
    Get.snackbar(
      'Fiscalizing',
      'Processing',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      showProgressIndicator: true,
    );
    String pingResponse = await ping();
    if(pingResponse.isNotEmpty){
      String apiEndpointSubmitReceipt =
      "https://fdmsapitest.zimra.co.zw/Device/v1/21659/SubmitReceipt";
      const String deviceModelName = "Server";
      const String deviceModelVersion = "v1";  

      SSLContextProvider sslContextProvider = SSLContextProvider();
      SecurityContext securityContext = await sslContextProvider.createSSLContext();
      final receiptJsonbody = await generateFiscalJSON();
      print(receiptJsonbody);
      // Call the Ping function
      Map<String, dynamic> response = await SubmitReceipts.submitReceipts(
        apiEndpointSubmitReceipt: apiEndpointSubmitReceipt,
        deviceModelName: deviceModelName,
        deviceModelVersion: deviceModelVersion,
        securityContext: securityContext,
        receiptjsonBody:receiptJsonbody,
      );
      print(response);
      Get.snackbar(
        "Zimra Response", "$response",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.message, color: Colors.white),
      );
      int statusCode = response["statusCode"];
      Map<String, dynamic> responseBody = jsonDecode(response["responseBody"]);
      Map<String, dynamic> jsonData = jsonDecode(receiptJsonbody);
      if (statusCode == 200) {
        final db=DatabaseHelper();

      print("Code is 200, saving receipt...");

      // Check if 'receiptPayments' is non-empty before accessing index 0
      String moneyType = (jsonData['receipt']['receiptPayments'] != null && jsonData['receipt']['receiptPayments'].isNotEmpty)
      ? jsonData['receipt']['receiptPayments'][0]['moneyTypeCode'].toString()
      : "";
      print("your date is ${jsonData['receipt']?['receiptDate']}");
      print("your invoice number is ${jsonData['receipt']?['invoiceNo']?.toString()}");
      print(jsonData);
      String submitReceiptServerresponseJson = responseBody.toString();
      int fiscalDayNo = await db.getlatestFiscalDay();
      print("fiscal day no is $fiscalDayNo");
      double receiptTotal = double.parse(jsonData['receipt']?['receiptTotal']?.toString() ?? "0");
      try {
        db.insertReceipt(SubmittedReceipt(
        receiptCounter: jsonData['receipt']?['receiptCounter'] ?? 0,
        fiscalDayNo: fiscalDayNo, 
        invoiceNo: int.tryParse(jsonData['receipt']?['invoiceNo']) ?? 0,
        receiptId: responseBody['receiptID'] ?? 0,
        receiptType: jsonData['receipt']['receiptType']?.toString() ?? "",
        receiptCurrency: jsonData['receipt']?['receiptCurrency']?.toString() ?? "",
        moneyType: moneyType,
        receiptDate: jsonData['receipt']?['receiptDate']?.toString() ?? "",
        receiptTime: jsonData['receipt']?['receiptDate']?.toString() ?? "",
        receiptTotal: receiptTotal,
        taxCode: "C",
        taxPercent: "15.00",
        taxAmount:  taxAmount ?? 0,
        salesAmountwithTax: salesAmountwithTax ?? 0,
        receiptHash: jsonData['receipt']?['receiptDeviceSignature']?['hash']?.toString() ?? "",
        receiptJsonbody: receiptJsonbody?.toString() ?? "",
        StatustoFdms: "Submitted",
        qrurl:"https://fdmsapitest.zimra.co.zw/Device/v1/21659/SubmitReceipt",
        receiptServerSignature: responseBody['receiptServerSignature']?['signature'].toString() ?? "",
        submitReceiptServerresponseJson: submitReceiptServerresponseJson,
        total15Vat: 0.0,
        totalNonVat: 0.0,
        totalExempt: 0.0,
        totalWt: 0.0));
      } catch (e) {
        Get.snackbar("Error",
          "$e",
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error),
        );
      }

}

      // String receiptServerSignature = response.receiptServerSignature.toString(); 
      // int receiptId = response.receiptID;
      // int statusCode = response.statusCode; 
      // print("your status code is$statusCode");
      //  Map<String, dynamic> jsonData = jsonDecode(receiptJsonbody);
      // if (statusCode == 200 || statusCode == 500){
      //   saveReceiptToDatabase(
      //     receiptCounter: int.parse(jsonData['receiptCounter']),
      //     fiscalDayNo: 1,
      //     invoiceNo: int.parse(jsonData['invoiceNo']),
      //     receiptType: jsonData['receiptType'].toString(),
      //     receiptCurrency: jsonData['receiptCurrency'].toString(),
      //     moneyType: jsonData['receiptPayments'][0]['moneyTypeCode'].toString(),
      //     receiptDate: jsonData['receiptDate'].toString(),
      //     receiptTime: jsonData['receiptDate'].toString(),
      //     receiptTotal: double.parse(jsonData['receiptTotal']),
      //     taxCode: "C",
      //     taxPercent: "15.00",
      //     taxAmount: taxAmount,
      //     salesAmountwithTax: salesAmountwithTax,
      //     receiptHash: jsonData['receiptDeviceSignature']['hash'].toString(),
      //     receiptJsonbody: receiptJsonbody.toString(),
      //     statustoFdms: "Submitted",
      //     qrurl: "https://fdmsapitest.zimra.co.zw/Device/v1/21659/SubmitReceipt",
      //     total15Vat: 0.0,
      //     totalNonVat: 0,
      //     totalExempt: 0,
      //     totalWt: 0,
      //     receiptId: receiptId,
      //     receiptServerSignature: receiptServerSignature.toString(),
      //     submitReceiptServerresponseJson: response.toString(),
      //   );
      // }
    }
  }
  completeSale() async {
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
      'Succes',
      'Sales Done',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
    );
    clearCart();
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

  ///=====PAYMENT METHODS=====//////////
  //////////////////////////////////////
  showProducts() async{
    products = await dbHelper.getAllProducts();
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
                        const Center(child: const Text("Products" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 15,),
                    
                    SizedBox(height: 10,),
                    Container(
                      height: 480,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                        color:const Color.fromARGB(255, 14, 19, 29),
                      ),
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context , index){
                          final product = products[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0), 
                              color: Colors.white, 
                            ),
                            child: ListTile(
                              title: Text(product['productName']),
                              subtitle: Text("Price: ${product['sellingPrice']}"),
                              trailing: IconButton(onPressed:()=>addToCart(product), icon:const Icon(Icons.add_circle_outline_sharp)),
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
                          //int cartItemQty = cartItems[index]['sellqty'];
                          if (direction == DismissDirection.endToStart) {
                            setState(() {
                              cartItems.removeAt(index);
                            });
                          }
                          else{
                            setState(() {
                              cartItems[index]['sellqty'] += 1;
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
                showProducts();
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
                                        onPressed: () async {
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
                                            await addItem();
                                            await generateFiscalJSON();
                                            //generateHash();
                                            await submitReceipt();
                                            await completeSale();
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