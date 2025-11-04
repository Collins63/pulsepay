import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/home/settings.dart';
import 'package:pulsepay/services/printerService.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterPage extends StatefulWidget {
  @override
  _SunmiPrinterPageState createState() => _SunmiPrinterPageState();
}

class _SunmiPrinterPageState extends State<SunmiPrinterPage> {
  bool _isConnected = false;
  bool _isPrinting = false;
  String _printerStatus = 'Checking...';
  List<BluetoothDevice> _devices = [];
  final GlobalKey _printKey = GlobalKey();
  bool _loading = true;
  BluetoothDevice? _connectedDevice;
  final PrinterService printerService = PrinterService();
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    await printerService.loadSavedPrinter();
    final devices = await printerService.getBondedDevices();

    setState(() {
      _devices = devices;
      _selectedDevice = printerService.connectedDevice;
      _loading = false;
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _loading = true);
    await printerService.connectToDevice(device);
    setState(() {
      _selectedDevice = device;
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connected to ${device.name}')),
    );
  }

   Future<void> _testPrint() async {
    await printerService.printTestReceipt();
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
    } catch (e) {
      print('Printer initialization error: $e');
      setState(() {
        _isConnected = false;
        _printerStatus = 'Printer initialization failed: ${e.toString()}';
      });
    }
  }

  Future<void> _checkPrinterStatus() async {
    setState(() {
      _printerStatus = 'Checking...';
    });
    
    await _initializePrinter();
  }

  Future<void> _printTestPage() async {
    if (!_isConnected) {
      _showMessage('Printer not available');
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      // Simple test print without complex formatting
      await SunmiPrinter.printText('SUNMI PRINTER TEST');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      //await SunmiPrinter.setFontSize(SunmiFontSize.LG);
      await SunmiPrinter.printText('TEST PAGE');
      await SunmiPrinter.resetFontSize();
      await SunmiPrinter.lineWrap(2);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('================================');
      await SunmiPrinter.printText('Device: Sunmi V2 Pro');
      await SunmiPrinter.printText('Date: ${DateTime.now().toString().split('.')[0]}');
      await SunmiPrinter.printText('================================');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('Sample Receipt');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('--------------------------------');
      
      await SunmiPrinter.printText('Item 1                    10.00');
      await SunmiPrinter.printText('Item 2                    15.50');
      await SunmiPrinter.printText('Item 3                     8.25');
      await SunmiPrinter.printText('--------------------------------');
      await SunmiPrinter.printText('TOTAL                     33.75');
      await SunmiPrinter.printText('--------------------------------');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('Thank you for testing!');
      await SunmiPrinter.printText('Sunmi printer is working');
      await SunmiPrinter.lineWrap(3);
      
      // Cut paper
      await SunmiPrinter.cutPaper();

      _showMessage('Test page printed successfully!');
    } catch (e) {
      print('Print error: $e');
      _showMessage('Print failed: ${e.toString()}');
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("Printer Setup" , style: TextStyle(fontSize: 16, color: Colors.white, fontWeight:  FontWeight.bold),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const Settings()),
          ),),
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Heading(text: "Inner Printer Settings"),
              // Status Card
              Card(
                color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        _isConnected ? Icons.print : Icons.print_disabled,
                        size: 48,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _printerStatus,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isConnected ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Refresh button
              ElevatedButton.icon(
                onPressed: _checkPrinterStatus,
                icon: Icon(Icons.refresh),
                label: Text('Check Printer Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Test print button
              ElevatedButton.icon(
                onPressed: _isConnected && !_isPrinting ? _printTestPage : null,
                icon: _isPrinting 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.print),
                label: Text(_isPrinting ? 'Printing...' : 'Print Test Page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.green: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Info text
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sunmi V2 Pro Information:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text('• Built-in thermal printer'),
                      Text('• No Bluetooth connection needed'),
                      Text('• Uses Sunmi proprietary APIs'),
                      Text('• Supports text, QR codes, and images'),
                      SizedBox(height: 8),
                      Text(
                        'Troubleshooting:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('• Make sure paper is loaded'),
                      Text('• Check printer tray is closed'),
                      Text('• Restart app if initialization fails'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Heading(text: "Bluetooth Printer"),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(text: "Bluetooth Printer service", style: appStyle(14,Colors.grey.shade800,FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadPrinters,
                    tooltip: 'Rescan Devices',
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              ReusableText(text: "Select a Bluetooth Printer", style: appStyle(14,Colors.grey.shade800,FontWeight.bold)),
              const SizedBox(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20)
                ),
                height: 200,
                child: ListView(
              children: [
                ..._devices.map((device) {
                  final isSelected =
                      _selectedDevice?.address == device.address;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0), 
                      color: Colors.white, 
                    ),
                    child: ListTile(
                      title: Text(device.name ?? "Unknown"),
                      subtitle: Text(device.address ?? ""),
                      trailing: isSelected
                          ? const Icon(Icons.circle, color: Colors.green)
                          : null,
                      onTap: () => _connect(device),
                    ),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
              ),
              Center(
                  child: ElevatedButton.icon(
                    onPressed: _testPrint,
                    icon: const Icon(Icons.print),
                    label: const Text("Test Print"),
                  ),
                ),
              ]
          )
        )
          )
          );
  }
}