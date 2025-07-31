import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/home/home_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});
  @override
  _InvoicesPageState createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllInvoices();
    setState(() {
      invoices = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        return Future.value(false);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50)
          ,child: AppBar(
            centerTitle: true,
            title: const Text("Invoices Summary" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()),
            )),
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Invoice ID')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Total Items')),
                            DataColumn(label: Text('Total Price')),
                            DataColumn(label: Text('Total Tax')),
                          ],
                          rows: invoices
                              .map(
                                (invoice) => DataRow(
                                  cells: [
                                    DataCell(Text(invoice['invoiceId'].toString())),
                                    DataCell(Text(invoice['date'].toString())),
                                    DataCell(Text(invoice['totalItems'].toString())),
                                    DataCell(Text(invoice['totalPrice'].toString())),
                                    DataCell(Text(invoice['totalTax'].toString())),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }
}
