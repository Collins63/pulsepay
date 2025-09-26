import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/heading.dart';

class Companysales extends StatefulWidget {
  const Companysales({super.key});

  @override
  State<Companysales> createState() => _CompanysalesState();
}

class _CompanysalesState extends State<Companysales> {


  DatabaseHelper dbHelper = DatabaseHelper();
  double? ZWGtotal;
  double? USDtotal;
  DateTime? _startDate;
  DateTime? _endDate;
  String? selectedCurrency;
  List<String> currencies = [];
  double? periodTotal;
  int? totalSales;
  Map<int, int>? salesCounts;

  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> topCustomers = [];
  List<Map<String, dynamic>> topCashiers = [];

  @override
  void initState(){
    dbHelper.getTopSellingProducts().then((value){
      setState(() {
        topProducts = value;
      });
    });
    dbHelper.getTopCustomers().then((value){
      setState(() {
        topCustomers = value;
      });
    });
    dbHelper.getTopSellingCashiers().then((value){
      setState(() {
        topCashiers = value;
      });
    });
    loadData();
    loadCurrencies();
    getZWGTotalSales();
    getUSDTotalSales();
    getAllReceipts();
  }

  Future<void> loadData() async {
    var data = await dbHelper.getMonthlySalesCounts();
    setState(() {
      salesCounts = data;
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

  Future<void> getAllReceipts()async{
    final receipts = await dbHelper.getSubmittedReceipts();
    int length = receipts.length;
    setState(() {
      totalSales = length;
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

  void getZWGTotalSales()async{
    final zwgRate = await dbHelper.getzwgcurrency();
    double rate = zwgRate[0]['rate'];
    final zwg = await dbHelper.getZWGTotalSales();
    double ZWGtotalcalcu =  zwg[0]['totalSales'] ?? 0 ;
    print("zwg = $zwg");
    setState(() {
       ZWGtotal = ZWGtotalcalcu * rate ;
    });
  }

  void getUSDTotalSales() async{
    final usd = await dbHelper.getUSDTotalSales();
    setState(() {
      USDtotal = usd[0]['totalSales'];  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("Company Sales" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade400
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text("Transactions", style: appStyle(16, Colors.white, FontWeight.bold) )),
                      SizedBox(height: 5,),
                      Center(child: Text("$totalSales", style: TextStyle(color: Colors.white, fontSize: 25), textAlign: TextAlign.center,))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                    
                        ),
                        color: Colors.green
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Text("ZWG Sales", style: appStyle(18, Colors.white, FontWeight.normal), textAlign: TextAlign.center,)),
                            SizedBox(height: 5,),
                            Center(child: Text(ZWGtotal.toString(), style: appStyle(18, Colors.white, FontWeight.normal), textAlign: TextAlign.center,))
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Expanded(
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10) 
                        ),
                        color: Colors.green
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Text("USD Sales", style: appStyle(18, Colors.white, FontWeight.normal), textAlign: TextAlign.center,)),
                            SizedBox(height: 5,),
                            Center(child: Text((USDtotal ?? 0).toStringAsFixed(2), style: appStyle(18, Colors.white, FontWeight.normal), textAlign: TextAlign.center,))
                          ],
                        ),
                      ),
                    ),
                  ),  
                ],
              ),
              const SizedBox(height: 40,),
              Container(
                height: 260,
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
                    const Heading(text: "Get Periodic Sales"),
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
                          final total = await dbHelper.getTotalSalesWithinDateRange(
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
                          child: Text("$periodTotal" , style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const SizedBox(height: 20,),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 4,
                      offset: const Offset(0, 6)
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Heading(text: 'Top Selling Products'),
                    const SizedBox(height: 20,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topProducts.length,
                        itemBuilder: (context, index){
                          final product = topProducts[index];
                          double totalSales = product['totalSales'];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0 , horizontal: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white
                            ),
                            child: ListTile(
                              title: Text(product['productName']),
                              subtitle: Text("Quantity: ${product['totalQuantity']}"),
                              trailing: Text("\$${totalSales.toStringAsFixed(2)}"),
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 4,
                      offset: const Offset(0, 6)
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Heading(text: 'Top Selling Cashiers'),
                    const SizedBox(height: 20,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topCashiers.length,
                        itemBuilder: (context, index){
                          final cashier = topCashiers[index];
                          double totalAmount = cashier['totalSales'];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0 , horizontal: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white
                            ),
                            child: ListTile(
                              title: Text(cashier['doneBY']),
                              subtitle: Text("Quantity: ${cashier['totalInvoices']}"),
                              trailing: Text("\$${totalAmount.toStringAsFixed(2)}"),
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 4,
                      offset: const Offset(0, 6)
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Heading(text: 'Top Customers'),
                    const SizedBox(height: 20,),
                    Expanded(
                      child: ListView.builder(
                        itemCount: topCustomers.length,
                        itemBuilder: (context, index){
                          final customers = topCustomers[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0 , horizontal: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white
                            ),
                            child: ListTile(
                              title: Text(customers['customerName']),
                              subtitle: Text("Quantity: ${customers['totalInvoices']}"),
                              trailing: Text("\$${customers['totalSpent']}"),
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              const Heading(text: 'Sales Charts'),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 4,
                      offset: const Offset(0, 6)
                    )
                  ]
                ),
                child: Padding(
                  padding:const EdgeInsets.all(10),
                  child: salesCounts == null
                  ? const Center(child: CircularProgressIndicator(),) :
                  MonthlySalesChart(salesCounts: salesCounts!)
                )
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlySalesChart extends StatelessWidget {
  final Map<int, int> salesCounts; // month -> sales count

  MonthlySalesChart({required this.salesCounts});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (salesCounts.values.isEmpty ? 1 : salesCounts.values.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false, reservedSize: 28),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: salesCounts[i + 1]!.toDouble(),
                color: Colors.amber,
                width: 16,
              )
            ],
          );
        }),
      ),
    );
  }
}