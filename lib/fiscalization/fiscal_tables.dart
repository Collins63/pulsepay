import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/fiscalization/open_day_table.dart';
import 'package:pulsepay/fiscalization/submitted_receipts_table.dart';

class FiscalTables extends StatelessWidget {
  const FiscalTables({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      appBar: PreferredSize(preferredSize: Size.fromHeight(50),
      child: CustomAppBar(
        text: 'Fiscal Tables',
        child: GestureDetector(
            onTap: (){
              Get.back();
            },
            child: const Icon(CupertinoIcons.arrow_left),
          )
      )
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start  ,
          children: [
            const SizedBox(height: 20), 
            CustomOutlineBtn(text: "Open Day", 
              color: kDark,
              color2: kDark,
              height: 50,
              onTap: (){
                Get.to(()=> const OpenDayTable());
              },
            ),
            const SizedBox(height: 20), 
            CustomOutlineBtn(text: "Daily Reports", 
              color: kDark,
              color2: kDark,
              height: 50,
              onTap: (){
                
              },
            ),
            const SizedBox(height: 20),
            CustomOutlineBtn(text: "Submitted Receipts", 
              color: kDark,
              color2: kDark,
              height: 50,
              onTap: (){
                Get.to(()=> const SubmittedReceiptsTable());  
              },
            )
          ],
        ),
      )
    ),
    );
  }
}