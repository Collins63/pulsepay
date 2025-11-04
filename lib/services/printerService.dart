import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;

  PrinterService._internal();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? _connectedDevice;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BlueThermalPrinter get printer => _bluetooth;

  /// Load saved printer from SharedPreferences
  Future<void> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('saved_printer_address');
    if (address != null) {
      final devices = await _bluetooth.getBondedDevices();
      final matched = devices.firstWhere(
        (d) => d.address == address,
        orElse: () => BluetoothDevice.fromMap({'name': '', 'address': ''}),
      );
      if (matched.address!.isNotEmpty) {
        await connectToDevice(matched);
      }
    }
  }

  /// Scan for bonded devices (previously paired)
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }

  /// Connect to a printer
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
      _connectedDevice = device;

      // Save the connected printer for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_printer_name', device.name ?? '');
      await prefs.setString('saved_printer_address', device.address ?? '');
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  /// Disconnect printer
  Future<void> disconnect() async {
    await _bluetooth.disconnect();
    _connectedDevice = null;
  }

  /// Print a test receipt
  Future<void> printTestReceipt() async {
    if (_connectedDevice == null) {
      print("No printer connected");
      return;
    }

    _bluetooth.printNewLine();
    _bluetooth.printCustom("PulsePay Test Receipt", 3, 1);
    _bluetooth.printNewLine();
    _bluetooth.printCustom("Printer Connected Successfully!", 1, 1);
    _bluetooth.printNewLine();
    _bluetooth.printQRcode("https://pulsepay.com", 200, 200, 1);
    _bluetooth.printNewLine();
    _bluetooth.paperCut();
  }
}
