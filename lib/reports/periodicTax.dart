import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/forms/reports.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class Periodictax extends StatefulWidget {
  const Periodictax({super.key});

  @override
  State<Periodictax> createState() => _PeriodictaxState();
}

class _PeriodictaxState extends State<Periodictax> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? selectedCurrency;
  List<String> currencies = [];
  double? periodTotal;
  int? totalSales;
  double taxTotal1 = 0.0;
  double taxTotal2 = 0.0;
  double taxTotal3 = 0.0;
  double totalTaxAmount = 0.0;
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _isConnected = false;
  bool _isPrinting = false;
  String _printerStatus = 'Checking...';
  int deviceID = 0;
  String? serialNo;
  String? tradeName;
  String? taxPayerTIN;
  String? taxPayerVatNumber;
  String? taxPayerAddress;
  String? taxPayerEmail;
  String? taxPayerPhone;
  String? modelName;
  List<Map<String , dynamic>> taxPayerDetails = [];
  List<Map<String , dynamic>> companyDetails = [];
  double GrossTotalZWG = 0;
  double TaxTotalZWG = 0;
  double NetVAT15TotalZWG = 0;
  double NetNonVATTotalZWG = 0;
  double NetExemptTotalZWG = 0;
  double NetTotalZWG = 0;
  double TaxVAT15ZWG = 0;
  double getGrossTotalVAT15ZWG = 0;
  double getGrossTotalNonVATZWG =0;
  double getGrossTotalExemptZWG = 0;
  double GrossTotalVAT15ZWG = 0;
  double GrossTotalNonVATZWG = 0;
  double GrossTotalExemptZWG = 0;
  double getTotalTaxAmount = 0;

  double GrossTotalUSD = 0;
  double TaxTotalUSD = 0;
  double NetVAT15TotalUSD = 0;
  double NetNonVATTotalUSD = 0;
  double NetExemptTotalUSD = 0;
  double NetTotalUSD = 0;
  double TaxVAT15USD = 0;
  double getGrossTotalVAT15USD = 0;
  double getGrossTotalNonVATUSD =0;
  double getGrossTotalExemptUSD = 0;
  double GrossTotalVAT15USD = 0;
  double GrossTotalNonVATUSD = 0;
  double GrossTotalExemptUSD = 0;
  double getTotalTaxAmountUSD = 0;

  double GrossTotalZAR = 0;
  double TaxTotalZAR = 0;
  double NetVAT15TotalZAR = 0;
  double NetNonVATTotalZAR = 0;
  double NetExemptTotalZAR = 0;
  double NetTotalZAR = 0;
  double TaxVAT15ZAR = 0;
  double getGrossTotalVAT15ZAR = 0;
  double getGrossTotalNonVATZAR =0;
  double getGrossTotalExemptZAR = 0;
  double GrossTotalVAT15ZAR = 0;
  double GrossTotalNonVATZAR = 0;
  double GrossTotalExemptZAR = 0;
  double getTotalTaxAmountZAR = 0;

  int InvoicesCountZWG = 0;
  double InvoicesTotalAmountZWG = 0;
  int CreditNotesCountZWG = 0; 
  double CreditNotesTotalAmountZWG = 0;
  int TotalDocumentsCountZWG = 0;
  double TotalDocumentsTotalAmountZWG = 0;

  int InvoicesCountUSD = 0;
  double InvoicesTotalAmountUSD = 0;
  int CreditNotesCountUSD = 0; 
  double CreditNotesTotalAmountUSD = 0;
  int TotalDocumentsCountUSD = 0;
  double TotalDocumentsTotalAmountUSD = 0;

  int InvoicesCountZAR = 0;
  double InvoicesTotalAmountZAR = 0;
  int CreditNotesCountZAR = 0; 
  double CreditNotesTotalAmountZAR = 0;
  int TotalDocumentsCountZAR = 0;
  double TotalDocumentsTotalAmountZAR = 0;

  @override
  void initState(){
    super.initState();
    loadCurrencies();
    getTaxPayerDetails();
    fetchCompanyDetails();
  }

  Future<void> _initializePrinter() async {
    try {
      // Initialize the printer first
      await SunmiPrinter.initPrinter();
      
      // Check if printer is available
      await SunmiPrinter.bindingPrinter();
      
      setState(() {
        _isConnected = true;
        _printerStatus = 'Sunmi Printer Ready';
      });
      print("Printer Initialized Successfully");
    } catch (e) {
      print('Printer initialization error: $e');
      setState(() {
        _isConnected = false;
        _printerStatus = 'Printer initialization failed: ${e.toString()}';
      });
    }
  }

  void getTaxPayerDetails() async{
    final data = await dbHelper.getTaxPayerDetails();
    setState(() {
      taxPayerDetails = data;
      tradeName = data[0]['taxPayerName'];
      taxPayerTIN = data[0]['taxPayerTin'];
      taxPayerVatNumber = data[0]['taxPayerVatNumber'];
      deviceID = data[0]['deviceID'];
      serialNo = data[0]['deviceModelName'];
      taxPayerAddress = data[0]['taxPayerAddress'];
      taxPayerEmail = data[0]['taxPayerEmail'];
      taxPayerPhone = data[0]['taxPayerPhone'];
    });
  }

  Future<void> fetchCompanyDetails() async{
    List<Map<String, dynamic>> data = await dbHelper.getCompanyDetails();
    setState(() {
      companyDetails = data;
    });
  }

  Future<void> prepareZWGZReportTotals(String startDate , String endDate)async{
    final ZWGtotals = await dbHelper.getZReportTotalsByDate('ZWG', startDate, endDate);
    GrossTotalZWG  = ZWGtotals[0]['sumZWGReceiptTotal'] ?? 0.0;
    TaxTotalZWG  = ZWGtotals[0]['sumZWGTaxAmount'] ?? 0.0;
    getGrossTotalVAT15ZWG =  ZWGtotals[0]['sumZWG15VAT']?? 0.0;
    getGrossTotalNonVATZWG = ZWGtotals[0]['sumZWGNonVAT']?? 0.0;
    getGrossTotalExemptZWG = ZWGtotals[0]['sumZWGExempt']?? 0.0;
    setState(() {
      TaxVAT15ZWG = TaxTotalZWG;
      GrossTotalVAT15ZWG = getGrossTotalVAT15ZWG;
      GrossTotalNonVATZWG =getGrossTotalNonVATZWG;
      GrossTotalExemptZWG = getGrossTotalExemptZWG;
    });
    //getZWLVAT gross total
    getTotalTaxAmount = ZWGtotals[0]['sumZWGTaxAmount']?? 0.0;
    NetVAT15TotalZWG = GrossTotalVAT15ZWG - getTotalTaxAmount;
    NetNonVATTotalZWG = GrossTotalNonVATZWG ;
    NetExemptTotalZWG = GrossTotalExemptZWG;
  }

  Future<void> prepareUSZreportTotals(String startDate , String endDate)async{
    final USDtotals = await dbHelper.getZReportTotalsByDate('USD' , startDate , endDate);
    GrossTotalUSD  = USDtotals[0]['sumZWGReceiptTotal']?? 0.0;
    TaxTotalUSD  = USDtotals[0]['sumZWGTaxAmount']?? 0.0;
    getGrossTotalVAT15USD =  USDtotals[0]['sumZWG15VAT']?? 0.0;
    getGrossTotalNonVATUSD = USDtotals[0]['sumZWGNonVAT']?? 0.0;
    getGrossTotalExemptUSD = USDtotals[0]['sumZWGExempt']?? 0.0;
    setState(() {
      TaxVAT15USD = TaxTotalUSD;
      GrossTotalVAT15USD = getGrossTotalVAT15USD;
      GrossTotalNonVATUSD =getGrossTotalNonVATUSD;
      GrossTotalExemptUSD = getGrossTotalExemptUSD;
    });

    getTotalTaxAmountUSD = USDtotals[0]['sumZWGTaxAmount']?? 0.0;
    NetVAT15TotalUSD = GrossTotalVAT15USD - getTotalTaxAmountUSD;
    NetNonVATTotalUSD = GrossTotalNonVATUSD ;
    NetExemptTotalUSD = GrossTotalExemptUSD;

  }

  Future<void> prepareZARZreportTotals(String startDate , String endDate)async{
      final ZARtotals = await dbHelper.getZReportTotalsByDate('ZAR' , startDate , endDate);
      GrossTotalZAR  = ZARtotals[0]['sumZWGReceiptTotal']?? 0.0;
      TaxTotalZAR  = ZARtotals[0]['sumZWGTaxAmount']?? 0.0;
      getGrossTotalVAT15ZAR =  ZARtotals[0]['sumZWG15VAT']?? 0.0;
      getGrossTotalNonVATZAR = ZARtotals[0]['sumZWGNonVAT']?? 0.0;
      getGrossTotalExemptZAR = ZARtotals[0]['sumZWGExempt']?? 0.0;
      setState(() {
        TaxVAT15ZAR = TaxTotalZAR;
        GrossTotalVAT15ZAR = getGrossTotalVAT15ZAR;
        GrossTotalNonVATZAR =getGrossTotalNonVATZAR;
        GrossTotalExemptZAR= getGrossTotalExemptZAR;
      });
      //getZWLVAT gross total

      getTotalTaxAmountZAR = ZARtotals[0]['sumZWGTaxAmount'] ?? 0.0;
      NetVAT15TotalZAR = GrossTotalVAT15ZAR - getTotalTaxAmountZAR;
      NetNonVATTotalZAR = GrossTotalNonVATZAR;
      NetExemptTotalZAR = GrossTotalExemptZAR;
  }

  Future<void> prepareZWGDocuments(String startDate, String endDate) async{
      final Invoices  = await dbHelper.getDocumentsCounterByDate('ZWG', 'FISCALINVOICE', startDate , endDate);
      final InvoicesTotal = await dbHelper.getZreportDocumentTotalsByDate('FISCALINVOICE' , 'ZWG' , startDate , endDate);
      final Creditnotes = await dbHelper.getDocumentsCounterByDate('ZWG', 'CREDITNOTE', startDate , endDate);
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotalsByDate('CREDITNOTE', 'ZWG', startDate , endDate);
      setState(() {
        InvoicesCountZWG = Invoices[0]['count']?? 0;
        InvoicesTotalAmountZWG = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountZWG = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountZWG = CreditnotesTotals[0]['total']?? 0.0;
      });
    }

    Future<void> prepareUSDDocuments(String startDate , String endDate) async{
      final Invoices  = await dbHelper.getDocumentsCounterByDate('USD', 'FISCALINVOICE' , startDate , endDate );
      final InvoicesTotal = await dbHelper.getZreportDocumentTotalsByDate('FISCALINVOICE' , 'USD' , startDate , endDate);
      final Creditnotes = await dbHelper.getDocumentsCounterByDate('USD', 'CREDITNOTE' , startDate , endDate );
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotalsByDate('CREDITNOTE', 'USD' , startDate , endDate);
      setState(() {
        InvoicesCountUSD = Invoices[0]['count']?? 0;
        InvoicesTotalAmountUSD = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountUSD = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountUSD = CreditnotesTotals[0]['total']?? 0.0;
      });
      print("Invoices Count USD: $InvoicesCountUSD");
      print("Invoices Total Amount USD: $InvoicesTotalAmountUSD");
    }

    Future<void> prepareZARDocuments(String startDate, String endDate) async{
      final Invoices  = await dbHelper.getDocumentsCounterByDate('ZAR', 'FISCALINVOICE' , startDate, endDate);
      final InvoicesTotal = await dbHelper.getZreportDocumentTotalsByDate('FISCALINVOICE' , 'ZAR' , startDate , endDate);
      final Creditnotes = await dbHelper.getDocumentsCounterByDate('ZAR', 'CREDITNOTE', startDate , endDate);
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotalsByDate('CREDITNOTE', 'ZAR' , startDate, endDate);
      setState(() {
        InvoicesCountZAR = Invoices[0]['count']?? 0;
        InvoicesTotalAmountZAR = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountZAR = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountZAR = CreditnotesTotals[0]['total']?? 0.0;
      });
    }

  void printPeriodZReport(String startDate , String endDate) async{
    await prepareZWGZReportTotals(startDate , endDate);
    await prepareZWGDocuments(startDate , endDate);
    await prepareUSZreportTotals(startDate , endDate);
    await prepareUSDDocuments(startDate , endDate);
    await prepareZARZreportTotals(startDate , endDate);
    await prepareZARDocuments(startDate , endDate);

    
    SunmiPrintAlign.CENTER;
    //await SunmiPrinter.setFontSize(SunmiFontSize.LG);
    await SunmiPrinter.printText("Z REPORT" , style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("${taxPayerDetails[0]['taxPayerName']}", style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.printText("TIN: ${taxPayerDetails[0]['taxPayerTin']}" ,style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.printText("VAT: ${taxPayerDetails[0]['taxPayerVatNumber']}" ,style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.printText("${companyDetails[0]['address']}", style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.printText("${companyDetails[0]['tel']}", style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.printText("================================");
    await SunmiPrinter.printText("Device Serial No: $serialNo");
    await SunmiPrinter.printText("Device Id: $deviceID");
    await SunmiPrinter.printText("Start Date: $startDate");
    await SunmiPrinter.printText("End Date: $endDate ");
    await SunmiPrinter.printText("================================");
    await SunmiPrinter.printText("Daily Totals", style: SunmiTextStyle( bold: true,align: SunmiPrintAlign.CENTER));
    await SunmiPrinter.printText("ZWG" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL NET SALES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Net , VAT 15%: ${NetVAT15TotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Net , Non-VAT 0%: ${NetNonVATTotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Net , Exempt: ${NetExemptTotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total Net Amount: ${NetTotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL TAXES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Tax , VAT 15 %: ${TaxVAT15ZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total tax amount: ${TaxTotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL GROSS SALES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Total , VAT 15 %: ${GrossTotalVAT15ZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total , Non-VAT 0 %: ${GrossTotalNonVATZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total , Exempt: ${GrossTotalExemptZWG.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total gross amount: ${GrossTotalZWG.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("Documents === Quantity === Total" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Invoices === ${InvoicesCountZWG.toStringAsFixed(2)} === ${InvoicesTotalAmountZWG.toStringAsFixed(2)} ");
    await SunmiPrinter.printText("Credit notes === ${CreditNotesCountZWG.toStringAsFixed(2)} === ${CreditNotesTotalAmountZWG.toStringAsFixed(2)} ");
    await SunmiPrinter.printText("Documents === ${TotalDocumentsCountZWG.toString()} === ${TotalDocumentsTotalAmountZWG.toString()} ");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("================================");
    await SunmiPrinter.printText("USD" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL NET SALES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Net , VAT 15%: ${NetVAT15TotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Net , Non-VAT 0%: ${NetNonVATTotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Net , Exempt: ${NetExemptTotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total Net Amount: ${NetTotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL TAXES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Tax , VAT 15 %: ${TaxVAT15USD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total tax amount: ${TaxTotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("TOTAL GROSS SALES" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Total , VAT 15 %: ${GrossTotalVAT15USD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total , Non-VAT 0 %: ${GrossTotalNonVATUSD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total , Exempt: ${GrossTotalExemptUSD.toStringAsFixed(2)}");
    await SunmiPrinter.printText("Total gross amount: ${GrossTotalUSD.toStringAsFixed(2)}");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.printText("Documents === Quantit === Total" ,style: SunmiTextStyle( bold: true));
    await SunmiPrinter.printText("Invoices === ${InvoicesCountUSD.toStringAsFixed(2)} === ${InvoicesTotalAmountZWG.toStringAsFixed(2)} ");
    await SunmiPrinter.printText("Credit notes === ${CreditNotesCountUSD.toStringAsFixed(2)} === ${CreditNotesTotalAmountZWG.toStringAsFixed(2)} ");
    await SunmiPrinter.printText("Documents === ${TotalDocumentsCountUSD.toString()} === ${TotalDocumentsTotalAmountZWG.toString()} ");
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.cutPaper();
  }



  void  getTaxTotalsByID(String startDate, String endDate) async{
    final receipts = await dbHelper.getAllFiscalInvoiceByDate(selectedCurrency , startDate, endDate);
    Map<String, double> totals = {
      "1": 0.0,
      "2": 0.0,
      "3": 0.0,
    };
    for(var receipt in receipts){
      final jsonBody = receipt['receiptJsonbody'];
      //print(jsonBody);
      if (jsonBody== null) continue;
      try {
        final Map<String , dynamic> receiptData = jsonDecode(jsonBody);
        if(receiptData['receipt']['receiptTaxes'] is List){
          List<dynamic> taxes = receiptData['receipt']['receiptTaxes'];
          //print(taxes);
          for(var tax in taxes){
            if(tax is Map<String, dynamic>){
              final String taxID = tax['taxID'] ?? '';
              if(totals.containsKey(taxID)){
                double amount = 0.0;
                if (tax['salesAmountWithTax'] is String){
                  amount = double.tryParse(tax['salesAmountWithTax']) ?? 0.0;
                }
                else if (tax['salesAmountWithTax'] is num){
                  amount = (tax['salesAmountWithTax'] as num).toDouble();
                }
                totals[taxID] = (totals[taxID] ?? 0.0) + amount;
              }
            }
            if(tax is Map<String,dynamic>){
              final String taxID = tax['taxID'] ?? '';
              if(totals.containsKey(taxID)){
                double taxAmount = 0.0;
                if(tax['taxAmount'] is String){
                  taxAmount = double.tryParse(tax['taxAmount']) ?? 0.0;
                }
                else if(tax['taxAmount'] is num){
                  taxAmount = (tax['taxAmount'] as num).toDouble();
                }
                totalTaxAmount += taxAmount;
              }
            }
          }
        }
        else{
          print("not taxes list");
        }
      } catch (e) {
        //print("json parsing error$e");
      }
    }
    totals.updateAll((key, value) => double.parse(value.toStringAsFixed(2)));
    print(totals);
    setState(() {
      taxTotal1 = totals["1"] ?? 0.0;
      taxTotal2 = totals["2"] ?? 0.0;
      taxTotal3 = totals["3"] ?? 0.0;
    });
  }

  Future<List<String>> fetchCurrencies() async{
    final List<Map<String, dynamic>> currencies = await dbHelper.getAllCurrencies();
    print(currencies);
    return currencies.map((row) => row['currency'] as String).toList();
  }

    Future<void> loadCurrencies()async{
    final results = await fetchCurrencies();
    setState(() {
      currencies = results;
    });
  }

  Future<void> selectedStartDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100)
    );
    if(picked != null){
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _startDate ?? DateTime.now(),
    firstDate: _startDate ?? DateTime(2024),
    lastDate: DateTime(2100),
  );
  if (picked != null) {
    setState(() {
      _endDate = picked;
    });
  }
} 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("Period Tax Returns" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Reports()));
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
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 6),
                        blurRadius: 10,
                        spreadRadius: 4
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      const Heading(text: "Get Periodic Tax"),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: ()=> selectedStartDate(context),
                                child: const Text("Selected Start Date")
                              )   ,
                              Text(_startDate != null
                                ? _startDate!.toLocal().toString().split('T').first
                                : "No Date"
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                            onPressed: () => selectEndDate(context),
                            child: Text("Select End Date"),
                          ),
                          Text(_endDate != null
                              ? _endDate!.toLocal().toString().split('T').first
                              : "No date"
                          ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButton<String>(
                          menuWidth: 200,
                          hint: Text("Select Currency"),
                          value: selectedCurrency,
                          onChanged: (value) async{
                            setState(() {
                              selectedCurrency = value;
                            });
                            totalTaxAmount = 0;
                            taxTotal1 = 0;
                            taxTotal2 = 0;
                            taxTotal3 = 0;
                            getTaxTotalsByID(_startDate!.toIso8601String() , _endDate!.toIso8601String());
                            final total = await dbHelper.getTotalTaxWithinDateRange(
                              currency: selectedCurrency.toString(),
                              startDate: _startDate!.toIso8601String(),
                              endDate: _endDate!.add(const Duration(hours: 23 , minutes: 59 , seconds: 59)).toIso8601String(),
                            );
                            setState(() {
                              periodTotal = total;
                            });
                          },
                          items: currencies.map((currency) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text( periodTotal != null ? "${periodTotal!.toStringAsFixed(2)}" : "0.00" , style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children:[
                                const SizedBox(height: 15,),
                                const Text("Total Tax Returns" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                                const SizedBox(height: 10,),
                                Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                                    ),
                                  ),
                                Text("${totalTaxAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                              ] 
                            ),
                          ),
                          Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,  
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children:[
                                const SizedBox(height: 15,),
                                const Text("15% Tax" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                                const SizedBox(height: 10,),
                                Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                                    ),
                                  ),
                                Text("$taxTotal1", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                              ] 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children:[
                                const SizedBox(height: 15,),
                                const Text("Zero Tax" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                                const SizedBox(height: 10,), 
                                Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                                    ),
                                  ),
                                Text("$taxTotal2", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                              ] 
                            ),
                          ),
                          Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              children:[
                                const SizedBox(height: 15,),
                                const Text("Tax Exempted" , style: TextStyle(fontSize: 14, color: Colors.black,fontWeight:  FontWeight.w500),),
                                const SizedBox(height: 10,),
                              Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Icon(Icons.monetization_on_rounded , color: Colors.blue, size: 30,),
                                    ),
                                  ),
                                Text("$taxTotal3", style: TextStyle(fontSize: 20  , fontWeight: FontWeight.bold , color: Colors.black),)
                              ] 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      FilledButton.icon(
                        onPressed: (){
                          printPeriodZReport(_startDate!.toIso8601String() , _endDate!.toIso8601String());
                        },
                        label:  ReusableText(text: "Print Report", style: appStyle(14, Colors.white, FontWeight.w500)),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                        icon: const Icon(Icons.print, color: Colors.white,),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}