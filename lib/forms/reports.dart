

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/forms/my_taxes.dart';
import 'package:pulsepay/home/home_page.dart';
import 'package:pulsepay/reports/companySales.dart';
import 'package:pulsepay/reports/customerPurchases.dart';
import 'package:pulsepay/reports/customerslist.dart';
import 'package:pulsepay/reports/end_of_daySlip.dart';
import 'package:pulsepay/reports/fiscalizedCustomer.dart';
import 'package:pulsepay/reports/periodicTax.dart';
import 'package:pulsepay/reports/salesForProduct.dart';
import 'package:pulsepay/reports/sales_report.dart';
import 'package:pulsepay/services/printerService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class Reports extends StatefulWidget{
  const Reports({super.key});

  @override
  State<Reports> createState() => _reportsState();
}

class _reportsState extends State<Reports>{

  @override
  void initState(){
    super.initState();
    getlatestFiscalDay();
    fetchCompanyDetails();
    getTaxPayerDetails();
    getGeneralSettings();
  }

  bool _isConnected = false;
  bool _isPrinting = false;
  String _printerStatus = 'Checking...';
  int currentFiscal = 0;
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
  final printerService = PrinterService();
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
    DatabaseHelper dbHelper = DatabaseHelper();
    bool hasBluetoothPrinter = false;

    Future<int> getlatestFiscalDay() async {
      int latestFiscDay = await dbHelper.getlatestFiscalDay();
      setState(() {
        currentFiscal = latestFiscDay;
      });
      return latestFiscDay;
    }

     Future<void> getGeneralSettings() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        hasBluetoothPrinter = prefs.getBool('hasBluetoothPrinter') ?? false;
      });
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


    Future<void> prepareZWGZReportTotals() async{
      final ZWGtotals = await dbHelper.getZReportTotals(currentFiscal ,  'ZWG');
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

    Future<void> prepareUSZreportTotals()async{
      final USDtotals = await dbHelper.getZReportTotals(currentFiscal ,  'USD');
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

    Future<void> prepareZARZreportTotals()async{
      final ZARtotals = await dbHelper.getZReportTotals(currentFiscal ,  'ZAR');
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

    Future<void> prepareZWGDocuments() async{
      final Invoices  = await dbHelper.getDocumentsCounter(currentFiscal, 'ZWG', 'FISCALINVOICE');
      final InvoicesTotal = await dbHelper.getZreportDocumentTotals(currentFiscal ,'FISCALINVOICE' , 'ZWG');
      final Creditnotes = await dbHelper.getDocumentsCounter(currentFiscal, 'ZWG', 'CREDITNOTE');
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotals(currentFiscal, 'CREDITNOTE', 'ZWG');
      setState(() {
        InvoicesCountZWG = Invoices[0]['count']?? 0;
        InvoicesTotalAmountZWG = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountZWG = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountZWG = CreditnotesTotals[0]['total']?? 0.0;
      });
      TotalDocumentsCountZWG = InvoicesCountZWG + CreditNotesCountZWG;
      TotalDocumentsTotalAmountZWG = InvoicesTotalAmountZWG + CreditNotesTotalAmountZWG;
    }

    Future<void> prepareUSDDocuments() async{
      final Invoices  = await dbHelper.getDocumentsCounter(currentFiscal, 'USD', 'FISCALINVOICE');
      final InvoicesTotal = await dbHelper.getZreportDocumentTotals(currentFiscal ,'FISCALINVOICE' , 'USD');
      final Creditnotes = await dbHelper.getDocumentsCounter(currentFiscal, 'USD', 'CREDITNOTE');
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotals(currentFiscal, 'CREDITNOTE', 'USD');
      setState(() {
        InvoicesCountUSD = Invoices[0]['count']?? 0;
        InvoicesTotalAmountUSD = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountUSD = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountUSD = CreditnotesTotals[0]['total']?? 0.0;
      });
      print("Invoices Count USD: $InvoicesCountUSD");
      print("Invoices Total Amount USD: $InvoicesTotalAmountUSD");
      TotalDocumentsCountUSD = InvoicesCountUSD + CreditNotesCountUSD;
      TotalDocumentsTotalAmountUSD = InvoicesTotalAmountUSD + CreditNotesTotalAmountUSD;
    }

    Future<void> prepareZARDocuments() async{
      final Invoices  = await dbHelper.getDocumentsCounter(currentFiscal, 'ZAR', 'FISCALINVOICE');
      final InvoicesTotal = await dbHelper.getZreportDocumentTotals(currentFiscal ,'FISCALINVOICE' , 'ZAR');
      final Creditnotes = await dbHelper.getDocumentsCounter(currentFiscal, 'ZAR', 'CREDITNOTE');
      final CreditnotesTotals = await dbHelper.getZreportDocumentTotals(currentFiscal, 'CREDITNOTE', 'ZAR');
      setState(() {
        InvoicesCountZAR = Invoices[0]['count']?? 0;
        InvoicesTotalAmountZAR = InvoicesTotal[0]['total']?? 0.0;
        CreditNotesCountZAR = Creditnotes[0]['count']?? 0;
        CreditNotesTotalAmountZAR = CreditnotesTotals[0]['total']?? 0.0;
      });
      TotalDocumentsCountZAR = InvoicesCountZAR + CreditNotesCountZAR;
      TotalDocumentsTotalAmountZAR = InvoicesTotalAmountZAR + CreditNotesTotalAmountZAR;
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

  String dayOpened = '';
  
  Future<void> getopendayData() async {
    final dayData = await dbHelper.getDayOpenedDate(currentFiscal);
    String dayOpened1 = dayData[0]['FiscalDayOpened'];
    print(dayOpened1);
    setState(() {
      dayOpened = dayOpened1;
    });
  }

  void printZReport() async{
    await printerService.loadSavedPrinter(); // ensures printer is loaded
    final printer = printerService.printer;
    await prepareZWGZReportTotals();
    await prepareZWGDocuments();
    await prepareUSZreportTotals();
    await prepareUSDDocuments();
    await prepareZARZreportTotals();
    await prepareZARDocuments();

    if(hasBluetoothPrinter = false){
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
      await SunmiPrinter.printText("Fiscal Day No: $currentFiscal");
      await SunmiPrinter.printText("Fiscal Day Opened: $dayOpened");
      await SunmiPrinter.printText("Device Serial No: $serialNo");
      await SunmiPrinter.printText("Device Id: $deviceID");
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
      await SunmiPrinter.printText("Credit notes === ${CreditNotesCountZWG.toStringAsFixed(2)} === ${CreditNotesTotalAmountZWG.toStringAsFixed(2)}");
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
      await SunmiPrinter.printText("Invoices === ${InvoicesCountUSD.toStringAsFixed(2)} === ${InvoicesTotalAmountUSD.toStringAsFixed(2)} ");
      await SunmiPrinter.printText("Credit notes === ${CreditNotesCountUSD.toStringAsFixed(2)} === ${CreditNotesTotalAmountUSD.toStringAsFixed(2)} ");
      await SunmiPrinter.printText("Documents === ${TotalDocumentsCountUSD.toString()} === ${TotalDocumentsTotalAmountUSD.toString()} ");
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText("================================");
      await SunmiPrinter.printText("ZAR" ,style: SunmiTextStyle( bold: true));
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText("TOTAL NET SALES" ,style: SunmiTextStyle( bold: true));
      await SunmiPrinter.printText("Net , VAT 15%: ${NetVAT15TotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Net , Non-VAT 0%: ${NetNonVATTotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Net , Exempt: ${NetExemptTotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Total Net Amount: ${NetTotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText("TOTAL TAXES" ,style: SunmiTextStyle( bold: true));
      await SunmiPrinter.printText("Tax , VAT 15 %: ${TaxVAT15ZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Total tax amount: ${TaxTotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText("TOTAL GROSS SALES" ,style: SunmiTextStyle( bold: true));
      await SunmiPrinter.printText("Total , VAT 15 %: ${GrossTotalVAT15ZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Total , Non-VAT 0 %: ${GrossTotalNonVATZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Total , Exempt: ${GrossTotalExemptZAR.toStringAsFixed(2)}");
      await SunmiPrinter.printText("Total gross amount: ${GrossTotalZAR.toStringAsFixed(2)}");
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.printText("Documents === Quantit === Total" ,style: SunmiTextStyle( bold: true));
      await SunmiPrinter.printText("Invoices === ${InvoicesCountZAR.toStringAsFixed(2)} === ${InvoicesTotalAmountZAR.toStringAsFixed(2)} ");
      await SunmiPrinter.printText("Credit notes === ${CreditNotesCountZAR.toStringAsFixed(2)} === ${CreditNotesTotalAmountZAR.toStringAsFixed(2)} ");
      await SunmiPrinter.printText("Documents === ${TotalDocumentsCountZAR.toString()} === ${TotalDocumentsTotalAmountZAR.toString()} ");
      await SunmiPrinter.cutPaper();
    }else{
      printer.printNewLine();
      printer.printCustom("Z REPORT", 3, 1);
      printer.printNewLine();
      printer.printCustom("${taxPayerDetails[0]['taxPayerName']}", 1, 1);
      printer.printCustom("${taxPayerDetails[0]['taxPayerVatNumber']}", 1, 1);
      printer.printCustom("${companyDetails[0]['address']}", 1, 1);
      printer.printCustom("${companyDetails[0]['tel']}", 1, 1);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("Fiscal Day No: $currentFiscal", 1, 0);
      printer.printCustom("Fiscal Day Opened: $dayOpened", 1, 0);
      printer.printCustom("Device Serial No: $serialNo", 1, 0);
      printer.printCustom("Device Id: $deviceID", 1, 0);
      printer.printCustom("================================", 1, 0);
      printer.printCustom("Daily Totals", 3, 1);
      printer.printNewLine();
      printer.printCustom("ZWG", 2, 0);
      printer.printCustom("TOTAL NET SALES", 2, 0);
      printer.printCustom("Net , VAT 15%: ${NetVAT15TotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Non-VAT 0%: ${NetNonVATTotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Exempt: ${NetExemptTotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total Net Amount: ${NetTotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL TAXES", 2, 0);
      printer.printCustom("Tax , VAT 15 %: ${TaxVAT15ZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total tax amount: ${TaxTotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL GROSS SALES", 2, 0);
      printer.printCustom("Total , VAT 15 %: ${GrossTotalVAT15ZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Non-VAT 0 %: ${GrossTotalNonVATZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Exempt: ${GrossTotalExemptZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total gross amount: ${GrossTotalZWG.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("Documents === Quantity === Total", 1, 0);
      printer.printCustom("Invoices === ${InvoicesCountZWG.toStringAsFixed(2)} === ${InvoicesTotalAmountZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Credit notes === ${CreditNotesCountZWG.toStringAsFixed(2)} === ${CreditNotesTotalAmountZWG.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Documents === ${TotalDocumentsCountZWG.toString()} === ${TotalDocumentsTotalAmountZWG.toString()}", 1, 0);
      printer.printNewLine();
      printer.printCustom("================================", 1, 0);
      printer.printCustom("USD", 2, 0);
      printer.printCustom("TOTAL NET SALES", 2, 0);
      printer.printCustom("Net , VAT 15%: ${NetVAT15TotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Non-VAT 0%: ${NetNonVATTotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Exempt: ${NetExemptTotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total Net Amount: ${NetTotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL TAXES", 2, 0);
      printer.printCustom("Tax , VAT 15 %: ${TaxVAT15USD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total tax amount: ${TaxTotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL GROSS SALES", 2, 0);
      printer.printCustom("Total , VAT 15 %: ${GrossTotalVAT15USD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Non-VAT 0 %: ${GrossTotalNonVATUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Exempt: ${GrossTotalExemptUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total gross amount: ${GrossTotalUSD.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("Documents === Quantity === Total", 1, 0);
      printer.printCustom("Invoices === ${InvoicesCountUSD.toStringAsFixed(2)} === ${InvoicesTotalAmountUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Credit notes === ${CreditNotesCountUSD.toStringAsFixed(2)} === ${CreditNotesTotalAmountUSD.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Documents === ${TotalDocumentsCountUSD.toString()} === ${TotalDocumentsTotalAmountUSD.toString()}", 1, 0);
      printer.printNewLine();
      printer.printCustom("================================", 1, 0);
      printer.printCustom("ZAR", 2, 0);
      printer.printCustom("TOTAL NET SALES", 2, 0);
      printer.printCustom("Net , VAT 15%: ${NetVAT15TotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Non-VAT 0%: ${NetNonVATTotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Net , Exempt: ${NetExemptTotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total Net Amount: ${NetTotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL TAXES", 2, 0);
      printer.printCustom("Tax , VAT 15 %: ${TaxVAT15ZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total tax amount: ${TaxTotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("TOTAL GROSS SALES", 2, 0);
      printer.printCustom("Total , VAT 15 %: ${GrossTotalVAT15ZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Non-VAT 0 %: ${GrossTotalNonVATZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total , Exempt: ${GrossTotalExemptZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Total gross amount: ${GrossTotalZAR.toStringAsFixed(2)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("Documents === Quantity === Total", 1, 0);
      printer.printCustom("Invoices === ${InvoicesCountZAR.toStringAsFixed(2)} === ${InvoicesTotalAmountZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Credit notes === ${CreditNotesCountZAR.toStringAsFixed(2)} === ${CreditNotesTotalAmountZAR.toStringAsFixed(2)}", 1, 0);
      printer.printCustom("Documents === ${TotalDocumentsCountZAR.toString()} === ${TotalDocumentsTotalAmountZAR.toString()}", 1, 0);
      printer.printNewLine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("Reports" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Lottie.asset(
                      'assets/taxAnimation.json'
                    ),
                  ),
                ),
                  const SizedBox(height: 20,),
                  const Heading(text: "Sales Reports"),
                  const SizedBox(height: 20,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "User Based Sales",
                    color: Colors.blue,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=>const  SalesReportPage());
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Sales For Product",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Salesforproduct());
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Sales For Company",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Companysales());
                    },
                  ),
                  
                  
                  const SizedBox(height: 10,),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "End Of Day Slip",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=>  EndOfDayslip());
                    },
                  ),
                  const SizedBox(height: 20,),
                  const Heading(text: 'Customer Reports'),
                  const SizedBox(height: 20,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Customer Purchases",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Customerpurchases());
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Customer List For Company",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Customerslist());
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Fiscalized Customers",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Fiscalizedcustomers());
                    },
                  ),
                  const SizedBox(height: 20,),
                  const Heading(text: 'Tax'),
                  const SizedBox(height: 20,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Tax Returns For Company",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const MyTaxes());
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Periodic Tax Returns",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      Get.to(()=> const Periodictax());
                    },
                  ),
                  const SizedBox(height: 20,),
                  const Heading(text: 'Fiscal Reports'),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "Print Z Report",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
                      printZReport();
                    },
                  ),
                  const SizedBox(height: 10,),
                  CustomOutlineBtn(
                    height: 50,
                    text: "RePrint Receipt",
                    color: Colors.blue ,
                    color2: Colors.blue,
                    onTap: (){
      
                    },
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}