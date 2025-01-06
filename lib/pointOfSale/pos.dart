import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_field.dart';
import 'package:get/get.dart';
//import 'package:pulsepay/home/home_page.dart';

class Pos  extends StatefulWidget{
  const Pos({super.key});

  @override
  State<Pos> createState() => _PosState();
}

class _PosState extends State<Pos>{
  final TextEditingController controller = TextEditingController();
  final DatabaseHelper dbHelper  = DatabaseHelper();

  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> cartItems = [];


  //=================FUNCTIONS============================//
  //======================================================//
  void completeSale() async {
    final double totalAmount = calculateTotalPrice();
    final double totalTax = calculateTotalTax();
    final double indiTax = calculateIndividualtax();

    await dbHelper.saveSale(cartItems, totalAmount, totalTax , indiTax );

    // Clear the cart
    clearCart();
  
    // Notify user
    //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sale completed!")));
    Get.snackbar(
      'Succes',
      'Sales Done',
      icon: const Icon(Icons.check, color: Colors.white,),
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
    );
  }

  void clearCart(){
    setState(() {
      cartItems.clear();
    });
  }

  void searchProducts(String query) async{
    final results = await dbHelper.searchProducts(query);
    setState(() {
      searchResults = results;
    });
  }

  void addToCart(Map<String, dynamic> product) {
    //double qty = 1;
    setState(() {

      int index = cartItems.indexWhere((item) => item['productid']==product['productid']);
      if(index != -1){
        cartItems[index]['sellqty'] +=1;
      }else{
        Map<String, dynamic> updatedProduct = {...product};
        updatedProduct['sellqty'] = 1;
        cartItems.add(updatedProduct);
      }
      //if (cartItems.contains(product)){
        //qty += 1;
        //Map<String , dynamic> updatedProduct = {...product};
        //updatedProduct['sellqty'] = qty;
        //cartItems[cartItems.indexOf(product)] = updatedProduct;
      //}else{
        //Map<String , dynamic> updatedProduct = {...product};
        //updatedProduct['sellqty'] = qty;
        //cartItems.add(updatedProduct); //our line
        
     // }
      
    });
  }

  double calculateTotalTax() {
    double totalTax = 0.0;

    for (var item in cartItems) {
      final taxType = item['tax']; // e.g., 'vat', 'zero', 'ex'
      final sellingPrice = item['sellingPrice'];
      final quantity = item['sellqty'];

      // Determine the applicable tax rate
      double taxRate = 0.0;
      if (taxType == 'vat') {
        taxRate = 0.15; // 15% VAT
      } else if (taxType == 'zero' || taxType == 'ex') {
        taxRate = 0.0; // Zero-rated or exempted
      }

      // Calculate the tax for this item
      totalTax += sellingPrice * quantity * taxRate;
    }
    return totalTax;
  }

  double calculateIndividualtax(){
    double indiTax  = 0 ;
    for (var item in cartItems) {
      final taxType = item['tax']; // e.g., 'vat', 'zero', 'ex'
      final sellingPrice = item['sellingPrice'];
      final quantity = item['sellqty'];

      // Determine the applicable tax rate
      double taxRate = 0.0;
      if (taxType == 'vat') {
        taxRate = 0.15; // 15% VAT
      } else if (taxType == 'zero' || taxType == 'ex') {
        taxRate = 0.0; // Zero-rated or exempted
      }

      // Calculate the tax for this item
      indiTax = sellingPrice * quantity * taxRate;
    }
    return indiTax;
  }

 

  double calculateTotalPrice() {
    return cartItems.fold(0.0, (total, item) {
      return total + (item['sellingPrice']);
    });
  }

  addCustomerDetails(){
    return showCupertinoDialog(
      context: context,
        builder: (context) => CupertinoAlertDialog (
          title: const Text("add customer details"),
          content: const Text('Are you sure you want to remove this item?'),
                              actions: [
                                  TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
        ),
      );
  }

  

  


  

  //=================END OF FUNCTIONS============================//
  //======================================================//

  

  @override  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title:  ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.arrow_left_circle,
                      size: 30,
                    ),
                  ),
              ),
              CustomField(
                controller: controller,
                onChanged: searchProducts,
              ),
              GestureDetector(
                onTap: ()=> searchProducts(controller.text),
                child: const Icon(
                  CupertinoIcons.search_circle,
                  size: 30,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0 , vertical: 10.0) ,
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                  color:const Color.fromARGB(255, 14, 19, 29),
                ),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context , index){
                    final product = searchResults[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(10.0), 
                        color: Colors.white, 
                      ),
                      child: ListTile(
                        title: Text(product['productName']),
                        subtitle: Text("Price: \$${product['sellingPrice']}"),
                        trailing: IconButton(onPressed: ()=>addToCart(product), icon:const Icon(Icons.add_circle_outline_sharp)),
                      ),
                    );
                  }
                  ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      
                    },
                    child: const Center(
                      child: Icon(Icons.barcode_reader , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  //////////Button
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      addCustomerDetails();
                    },
                    child: const Center(
                      child: Icon(Icons.person , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  //////////Button
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      
                    },
                    child: const Center(
                      child: Icon(Icons.monetization_on , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  //////////Button
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      
                    },
                    child: const Center(
                      child: Icon(Icons.discount , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  //////////Button
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      
                    },
                    child: const Center(
                      child: Icon(Icons.save , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  //////////Button
                  Container(
                    height: 50 ,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,

                        )
                      ] 
                    ),
                    child: TextButton(onPressed: (){
                      
                    },
                    child: const Center(
                      child: Icon(Icons.scale , size: 25, color: Color.fromARGB(255, 14, 19, 29),),
                    )),
                  ),
                  
                ],
              ),
              const SizedBox(height: 20,),
              const Text(
                "Cart",
                style: TextStyle(fontSize: 16 , fontWeight: FontWeight.w500),
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                  color: const Color.fromARGB(255, 14, 19, 29),
                ),
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context , index){
                    final product = cartItems[index];
                    return Dismissible(
                      key: Key(product['productid'].toString()),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Swipe to the right to delete
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Item'),
                              content: const Text('Are you sure you want to remove this item?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          return confirm;
                        } else {
                            // Swipe to the left to add or subtract
                            //_showQuantityAdjustmentDialog(product);
                          return false; // Prevent dismissal
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0), 
                          color: Colors.white, 
                        ),
                        child: ListTile(
                            title: Text(product['productName']),
                            subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toUpperCase()}"),
                            trailing: IconButton(onPressed: (){}, icon:const Icon(Icons.minimize_outlined)),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 14, 19, 29),
                                borderRadius: BorderRadius.circular(50.0)
                              ),
                              child:  Center(
                                child:  Text(
                                  product['sellqty'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ),

                            ),
                          ),
                      ),
                    );
                  }
                  ),
              ),
              const SizedBox(height: 10,),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 14, 19, 29),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("USD: \$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        const SizedBox(width: 20),
                        //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        Text("QTY: ${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        const SizedBox(width: 20),
                        //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        //Text("\$${calculateTotalTax().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          )
        ),
        bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 14, 19, 29),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){

                },
                icon: const Column(
                  children: [
                    Icon(Icons.home, color: Colors.white,),
                    Text(
                        "Home",
                        style: TextStyle(fontSize: 10,color: Colors.white),
                    )
                  ],
                ),
            ),
            IconButton(
              onPressed: (){
                //Navigator.pushReplacement(
                  //context,
                  //MaterialPageRoute(builder: (context) => MyAccount()),
                //);
              },
              icon: const Column(
                children: [
                  Icon(Icons.list_alt, color: Colors.white),
                  Text(
                    "Products",
                    style: TextStyle(fontSize: 10  ,color: Colors.white),
                  )
                ],
              ),
            ),
            FloatingActionButton(
                onPressed: () async {
                  if(cartItems.isEmpty){
                    await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Empty Cart'),
                              content: const Text('You did not select any product to complate the sale'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Get Back'),
                                ),
                              ],
                            ),
                          );
                  }
                  else{
                    await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Column(
                                children: [
                                  const Text('Sale Summary', style:TextStyle(fontWeight: FontWeight.bold),),
                                  Text("USD: \$${calculateTotalPrice().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 20),),
                                  const SizedBox(width: 20),
                                  //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                  Text("Items: ${cartItems.length}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 20),),
                                  const SizedBox(width: 20),
                                  //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                  Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 20),),
                        
                                ],
                              ),
                              content: ListView.builder(
                                itemCount: cartItems.length,
                                itemBuilder: (context , index){
                                final product = cartItems[index];
                                return 
                                  ListTile(
                                    title: Text(product['productName']),
                                    subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toUpperCase()}"),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 14, 19, 29),
                                        borderRadius: BorderRadius.circular(50.0)
                                      ),
                                      child:  Center(
                                        child:  Text(
                                          product['sellqty'].toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                        ),
                                      ),

                                    ),
                                  )
                                ;
                              }                                
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    completeSale();
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Complete Sale'),
                                ),
                              ],
                            ),
                          );
                  }
                  
                },
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.done_outline_rounded,
                  color: Colors.white,
                ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => MyLoans()),
                //);
              },
              icon: const Column(
                children: [
                  Icon(Icons.summarize, color: Colors.white),
                  Text(
                    "Reporting",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clearing Cart!!'),
                              content: const Text('Are you sure you want to cancel the sale'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Get Back'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setState(() {
                                      cartItems.clear();
                                    });
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => Profile()),
               // );
              },
              icon: const Column(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  Text(
                    "Cancel",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );

    
  }
}