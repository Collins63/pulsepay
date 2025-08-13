import 'package:flutter/material.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/heading.dart';
import 'package:pulsepay/forms/reports.dart';

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
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState(){
    super.initState();
    loadCurrencies();
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
                            child: Text("${periodTotal!.toStringAsFixed(2)}" , style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),),
                          ),
                        ),
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