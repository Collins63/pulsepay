import 'package:flutter/material.dart';
import 'package:pulsepay/common/appStyle.dart';
import 'package:pulsepay/common/reusable_text.dart';

class Heading extends StatelessWidget{
  const Heading ({super.key,  required this.text});

  final String? text;
  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: const Color(0xffC5C5C5),
            )
          ),
        ),
        const SizedBox(width: 5,),
        ReusableText(text: text!, style: appStyle(16, Colors.grey, FontWeight.w500)),
        const SizedBox(width: 5,),
        Container(
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1,
              color: const Color(0xffC5C5C5),
            )
          ),
        ),
      ],
    );
  }

}