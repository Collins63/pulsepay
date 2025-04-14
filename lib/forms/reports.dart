

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/reusable_text.dart';
import 'package:pulsepay/reports/end_of_daySlip.dart';
import 'package:pulsepay/reports/sales_report.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(50),
        child: CustomAppBar(
          text: 'Reports',
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          )
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
                const SizedBox(height: 10,),
                const ReusableText(text: "Sales Reports", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                Container(
                  height: 5,
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kDark
                  ),
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Sales For Period All Users",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=> SalesReportPage());
                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Sales For Product",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Sales For Company",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                
                
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Sales By Payment Method",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  text: "End Of Day Slip",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=> const EndOfDayslip());
                  },
                ),
                const SizedBox(height: 20,),
                const ReusableText(text: "Stock Reports", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                Container(
                  height: 5,
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kDark
                  ),
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Stock Balance For Branch",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "View Stock Purchses",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Individual Product Movement",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Highest Movers",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Stock Expiry",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Price List",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Perfomance Report",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 20,),
                const ReusableText(text: "Customer Reports", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                Container(
                  height: 5,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kDark
                  ),
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Customer Purchases For Period",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Customer List For Company",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Fiscalized Customers",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                // const SizedBox(height: 20,),
                // const ReusableText(text: "Discounts Reports", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                // Container(
                //   height: 5,
                //   width: 140,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     color: kDark
                //   ),
                // ),
                // const SizedBox(height: 10,),
                // CustomOutlineBtn(
                //   height: 50,
                //   width: 340,
                //   text: "Discounts Given For Period",
                //   color: kDark ,
                //   color2: kDark,
                //   onTap: (){

                //   },
                // ),
                const SizedBox(height: 20,),
                const ReusableText(text: "Tax", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kDark
                  ),
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Tax Returns For Company",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 20,),
                const ReusableText(text: "Fiscal Reports", style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 16)),
                Container(
                  height: 5,
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kDark
                  ),
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Print Z Report",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "Print X Report",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
                const SizedBox(height: 10,),
                CustomOutlineBtn(
                  height: 50,
                  width: 340,
                  text: "RePrint Receipt",
                  color: kDark ,
                  color2: kDark,
                  onTap: (){

                  },
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}