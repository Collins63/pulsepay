import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/common/reusable_text.dart';

class EndOfDayslip extends StatelessWidget {
  const EndOfDayslip({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: CustomAppBar(
          text: "End OF Day Slip",
          child: GestureDetector(
            onTap: (){
              Get.back();
            },
            child: const Icon(CupertinoIcons.arrow_left),
          ) 
        )
      ),
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50,),
            const Center(child: ReusableText(text: "Print Options", style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500))),
            const SizedBox(height: 20,),
            CustomOutlineBtn(
              text: "Print For All",
              color: kDark,
              color2: kDark,
              height: 50,
              onTap: (){

              },
            ),
            const SizedBox(height: 20,),
            const Center(child: ReusableText(text: "Print For User", style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500))),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: const Color(0xffC5C5C5),
                )
              ),
            ),
            CustomOutlineBtn(
              text: "Print For User",
              color: kDark,
              color2: kDark,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}