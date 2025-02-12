import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/fiscalization/get_status.dart';
import 'package:pulsepay/fiscalization/ping.dart';
import 'package:pulsepay/fiscalization/sslContextualization.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/home/settings.dart';
import 'package:pulsepay/pointOfSale/pos.dart';

class FiscalPage extends StatefulWidget {
  const FiscalPage({super.key});

  @override
  State<FiscalPage> createState() => _FiscalPageState();
}

class _FiscalPageState extends State<FiscalPage> {
  final DatabaseHelper dbHelper  = DatabaseHelper();
  String deviceID = "21659";
  String taxPayerName = "TestWellEast Investments";
  String tinNumber = "2000874913";
  String vatNumber = "220280877";
  String serialNumber = "testwelleast-1";
  String modelName = "Server";
  List<Map<String, dynamic>> receiptsPending= [];
  List<Map<String, dynamic>> receiptsSubmitted= [];
  List<Map<String , dynamic>> allReceipts=[];

  Future<void> fetchReceiptsPending() async {
    List<Map<String, dynamic>> data = await dbHelper.getReceiptsPending();
    setState(() {
      receiptsPending = data;
    });
  }
  Future <void> fetchReceiptsSubmitted() async{
    List<Map<String ,dynamic>> data  = await dbHelper.getSubmittedReceipts();
    setState(() {
      receiptsSubmitted = data;
    });
  }
  Future <void> fetchAllReceipts() async{
    List<Map<String ,dynamic>> data  = await dbHelper.getAllReceipts();
    setState(() {
      allReceipts = data;
    });
  }

  ///MANUAL OPENDAY
  Future<String> openDayManual() async {
  final dbHelper = DatabaseHelper();
  final previousData = await dbHelper.getPreviousReceiptData();
  final previousFiscalDayNo = await dbHelper.getPreviousFiscalDayNo();
  final taxIDSetting = await getConfig();

  int fiscalDayNo = (previousData["receiptCounter"] == 0 &&
          previousData["receiptGlobalNo"] == 0)
      ? 1
      : previousFiscalDayNo + 1;

  String iso8601 = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());

  String openDayRequest = jsonEncode({
    "fiscalDayNo": fiscalDayNo,
    "fiscalDayOpened": iso8601,
    "taxID": taxIDSetting,
  });

  print("Open Day Request JSON: $openDayRequest");

  try {
    final response = await http.post(
      Uri.parse("https://fdmsapitest.zimra.co.zw/Device/v1/21659/OpenDay"), // Update this URL
      headers: {
        "Content-Type": "application/json",
        "DeviceModelName": "Server",
        "DeviceModelVersion": "v1"
      },
      body: openDayRequest,
    );
    if (response.statusCode == 200) {
      print("Open Day posted successfully!");
      await dbHelper.insertOpenDay(fiscalDayNo, "unprocessed", iso8601);
      return "Open Day Successfully Recorded!";
    } else {
      print("Failed to post Open Day: ${response.body}");
      return "Failed to post Open Day";
    }
  } catch (e) {
    print("Error sending request: $e");
    return "Connection error";
  }
}

Future<String> getConfig() async {
  String apiEndpointGetConfig = "https://fdmsapitest.zimra.co.zw/Device/v1/21659/GetConfig"; // Replace with actual API endpoint
  String responseMessage = "There was no response from the server. Check your connection !!";

  try {
    final uri = Uri.parse(apiEndpointGetConfig);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'DeviceModelName': 'Server', // Replace with actual model
        'DeviceModelVersion': 'v1' // Replace with actual version
      },
    );

    if (response.statusCode == 200) {
      print("Get Config request sent successfully :)");
      print(response.body);

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Extract data from JSON
      String taxPayerName = jsonResponse["taxPayerName"];
    String taxPayerTIN = jsonResponse["taxPayerTIN"]; // Keep as String
    String vatNumber = jsonResponse["vatNumber"]; // Keep as String
    String deviceSerialNo = jsonResponse["deviceSerialNo"];
    String deviceBranchName = jsonResponse["deviceBranchName"];

      // Extract address details
    Map<String, dynamic> deviceBranchAddress = jsonResponse["deviceBranchAddress"];
    String province = deviceBranchAddress["province"];
    String street = deviceBranchAddress["street"];
    String houseNo = deviceBranchAddress["houseNo"];
    String city = deviceBranchAddress["city"];

      // Extract contact details
    Map<String, dynamic> deviceBranchContacts = jsonResponse["deviceBranchContacts"];
    String phoneNo = deviceBranchContacts["phoneNo"];
    String email = deviceBranchContacts["email"];

     // Other device details
    String deviceOperatingMode = jsonResponse["deviceOperatingMode"];
    int taxPayerDayMaxHrs = jsonResponse["taxPayerDayMaxHrs"]; // Already an int
    String certificateValidTill = jsonResponse["certificateValidTill"];
    String qrUrl = jsonResponse["qrUrl"];
    int taxpayerDayEndNotificationHrs = jsonResponse["taxpayerDayEndNotificationHrs"]; // Already an int
    String operationID = jsonResponse["operationID"];
    
      // Extract applicable taxes
      List<dynamic> applicableTaxes = jsonResponse["applicableTaxes"];
      Map<String, int> taxIDs = {};

      for (var tax in applicableTaxes) {
        String taxName = tax["taxName"];
        int taxID = int.tryParse(tax["taxID"].toString()) ?? 0; 

        if (taxName == "Standard rated 15%") {
          taxIDs["VAT15"] = taxID;
        } else if (taxName == "Zero rated 0%" || taxName == "Zero rate 0%") {
          taxIDs["Zero"] = taxID;
        } else if (taxName == "Exempt") {
          taxIDs["Exempt"] = taxID;
        } else if (taxName == "Non-VAT Withholding Tax") {
          taxIDs["WT"] = taxID;
        }
      }

      // Store tax details in SQLite database
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateDatabase(taxIDs);

      responseMessage = """
        taxPayerName: $taxPayerName
        taxPayerTIN: $taxPayerTIN
        vatNumber: $vatNumber
        deviceSerialNo: $deviceSerialNo
        deviceBranchName: $deviceBranchName
        Address: $houseNo $street, $city, $province
        Contacts: Phone - $phoneNo, Email - $email
        Operating Mode: $deviceOperatingMode
        Max Hrs: $taxPayerDayMaxHrs
        Certificate Valid Till: $certificateValidTill
        QR URL: $qrUrl
        Notification Hrs: $taxpayerDayEndNotificationHrs
        Operation ID: $operationID
        Taxes: ${taxIDs.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
      """;

      print("Response received: $responseMessage");

      Get.snackbar("Zimra Response", responseMessage , 
      icon:const Icon(Icons.message),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP
      );

    } else {
      print("Failed to get config. Status code: ${response.statusCode}");
      Get.snackbar("Zimra Response", "Failed to get config. Status code: ${response.statusCode}" , 
      icon:const Icon(Icons.message),
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP
      );
    }
  } catch (e) {
    print("Error getting config: $e");
    Get.snackbar("Zimra Response", "Error getting config: $e" , 
      icon:const Icon(Icons.message),
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP
      );

  }

  return responseMessage;
}


  ///GETSTATUS
  
  Future<void> getStatus() async {
    String apiEndpointGetStatus =
      "https://fdmsapitest.zimra.co.zw/Device/v1/21659/GetStatus";
    const String deviceModelName = "Server";
    const String deviceModelVersion = "v1";

    SSLContextProvider sslContextProvider = SSLContextProvider();
    SecurityContext securityContext = await sslContextProvider.createSSLContext();

    final String response = await GetStatus.getStatus(
      apiEndpointGetStatus: apiEndpointGetStatus,
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
  }



  Future<void> ping() async {
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
}


// void main() {
//   // Call getStatus from the main method
//   getStatus();
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){Get.back();},
          icon: const Icon(Icons.arrow_circle_left_outlined , color: Colors.black ,size: 30,),
        ),
        centerTitle: true,
        title: const Text("Fiscal Configuration" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16),),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/zimra.PNG',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 15,),
                Container(
                  height:350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kDark,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0 ,top: 10.0),
                    child: ListView(
                      children: [
                        Text("TAXPAYER NAME: $taxPayerName" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16),),
                        const SizedBox(height: 6,),
                        Text("TAXPAYER TIN: $tinNumber" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("VAT NUMBER: $vatNumber" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("DEVICE ID: $deviceID" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("SERIAL NO: $serialNumber" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("MODEL NAME: $modelName" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("FSCAL DAY:" , style: const TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("TIME TO CLOSEDAY:" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("RECEIPT COUNTER: ${allReceipts.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("RECEIPTS SUBMITTED: ${receiptsSubmitted.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                        const SizedBox(height: 6,),
                        Text("RECEIPTS PENDING: ${receiptsPending.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.w500 , fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                const Center(child: ReusableText(text: "Functions", style: TextStyle(fontWeight: FontWeight.w500 ))),
                CustomOutlineBtn(
                  text: "Manual Open Day",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    openDayManual();
                  },
                  height: 50,
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  text: "Device Configuration",
                  color: kDark,
                  color2: kDark,
                  onTap: () {
                    getConfig();
                  },
                  height: 50,
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  text: "Device Status",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    getStatus();
                  },
                  height: 50,
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  text: "Ping Tests",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    ping();
                  },
                  height: 50,
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  text: "Manual Close Day",
                  color:kDark,
                  color2: kDark,
                  onTap: (){
          
                  },
                  height: 50,
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  text: "Submit Missing Receipts",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    
                  },
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Get.to(()=> const HomePage());
                },
                icon: const Column(
                  children: [
                    Icon(Icons.home, color: Colors.grey,),
                    Text(
                        "Home",
                        style: TextStyle(fontSize: 10),
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
                Get.to(()=> const FiscalPage());
              },
              icon: const Column(
                children: [
                  Icon(Icons.list_alt, color: Colors.black),
                  Text(
                    "Fiscalization",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            FloatingActionButton(
                onPressed: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Pos()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.calculate,
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
                  Icon(Icons.summarize, color: Colors.grey),
                  Text(
                    "Reporting",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => Profile()),
               // );
               Get.to(()=> const Settings());
              },
              icon: const Column(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  Text(
                    "Settings",
                    style: TextStyle(fontSize: 10),
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