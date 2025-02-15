import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pulsepay/SQLite/database_helper.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});
  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  String selectedPeriod = "Daily"; // Default selection
  List<BarChartGroupData> salesData = [];
  double totalSales = 0.0;
  DatabaseHelper db = DatabaseHelper(); 
  Future<void> fetchSalesData() async {
    List<Map<String, dynamic>> results =
        await db.getSalesReport(selectedPeriod);
    setState(() {
      salesData = results.asMap().entries.map((entry) {
        int index = entry.key;
        double value = entry.value['totalAmount'] ?? 0.0;
        return BarChartGroupData(
          x: index,
          barRods: [BarChartRodData(fromY: 0.0, toY: value, color: Colors.blue)],
        );
      }).toList();

      totalSales = results.fold(0.0, (sum, item) => sum + (item['totalAmount'] ?? 0.0));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sales Report")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select period
            DropdownButton<String>(
              value: selectedPeriod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPeriod = newValue!;
                  fetchSalesData();
                });
              },
              items: ["Daily", "Weekly", "Monthly"].map((String period) {
                return DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Bar Chart
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: salesData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Total Sales Summary
            Text(
              "Total Sales: \$${totalSales.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
