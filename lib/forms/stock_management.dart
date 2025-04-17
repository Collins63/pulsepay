import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/forms/edit_stock_purchases.dart';
import 'package:pulsepay/forms/new_stock_purchase.dart';
import 'package:pulsepay/forms/view_products.dart';
import 'package:pulsepay/forms/view_stock_balances.dart';

class StockManagement extends StatelessWidget {
  const StockManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Stock Management" , style: TextStyle(fontWeight: FontWeight.w500 , fontSize: 18),),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Get.back();
          },
          icon: const Icon(Icons.arrow_back)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomOutlineBtn(
                  height: 50,
                  text: "View Stock Balances",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=>const ViewStockBalances());
                  },
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Edit Product Details",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=> const ViewProducts());
                  },
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Add/Change BarCode",
                  color: kDark,
                  color2: kDark,
                  onTap: (){},
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Add/Change HSCode",
                  color: kDark,
                  color2: kDark,
                  onTap: (){},
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "New Stock Purchase",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    Get.to(()=> const NewStockPurchase());
                  },
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Edit Stock Purchaes",
                  color: kDark,
                  color2: kDark,
                  onTap: (){
                    Get.to(
                      ()=> const EditStockPurchases()
                    );
                  },
                ),
                const SizedBox(height: 15,),
                CustomOutlineBtn(
                  height: 50,
                  text: "Stock Take",
                  color: kDark,
                  color2: kDark,
                  onTap: (){},
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}