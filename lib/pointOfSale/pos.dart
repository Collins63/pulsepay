import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pulsepay/JsonModels/users.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
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
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController searchCustomer = TextEditingController();
  final DatabaseHelper dbHelper  = DatabaseHelper();

  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> customerDetails = [];
  List<Map<String, dynamic>> selectedCustomer =[];
  final formKey = GlobalKey<FormState>();
  final paidKey = GlobalKey<FormState>();
  bool isActve = true;
  //=================FUNCTIONS============================//
  //======================================================//
  void completeSale() async {
    final double totalAmount = calculateTotalPrice();
    final double totalTax = calculateTotalTax();
    final double indiTax = calculateIndividualtax();

    await dbHelper.saveSale(cartItems, totalAmount, totalTax , indiTax );

    // Clear the cart
    clearCart();
    paidController.clear();
    selectedCustomer.clear();
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

  void searchCustomerDetails(String query) async{
    final customerSearchResult = await dbHelper.searchCustomer(query);
    setState(() {
      customerDetails = customerSearchResult;
    });
  }

  void addToCustomer(Map<String , dynamic> customer){
    selectedCustomer.add(customer);
    Get.snackbar(
      "Success",
      "Customer Added",
      colorText: Colors.white,
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP
    );
    Navigator.pop(context);
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

  ///=====CUSTOMER DETAILS=====//////////
  //////////////////////////////////////
  addCustomerDetails(){
    return showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context){
        return Container(
          height: 600,
          child: Padding(
            padding:  EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom
            ),
            child: Form(
              key: formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: kDark,
                          borderRadius: BorderRadius.circular(20), 
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        }, icon:const Icon(Icons.arrow_circle_left_sharp, size: 40, color: kDark,)),
                        const Center(child: const Text("Customer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Existing?"),
                        SizedBox(height: 10,),
                        Expanded(
                          child: TextField(
                            controller: searchCustomer,
                            onChanged: searchCustomerDetails,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color:Colors.grey.shade600 ),
                              filled: true,
                              fillColor: Colors.grey.shade300,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none
                              )
                            ),
                            
                          )
                        ),
                        IconButton(
                          onPressed: (){
                            searchCustomerDetails(searchCustomer.text);
                            setState(() {
                              isActve = false;
                            });
                          },
                          icon: Icon(Icons.person_search_rounded)
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(width: 1 , color: const Color.fromARGB(255, 14, 19, 29)),
                        color:const Color.fromARGB(255, 14, 19, 29),
                      ),
                      child: ListView.builder(
                        itemCount: customerDetails.length,
                        itemBuilder: (context , index){
                          final customer = customerDetails[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0), 
                              color: Colors.white, 
                            ),
                            child: ListTile(
                              title: Text(customer['tradeName']),
                              subtitle: Text("Price: \$${customer['tinNumber']}"),
                              trailing: IconButton(onPressed: ()=>addToCustomer(customer), icon:const Icon(Icons.add_circle_outline_sharp)),
                            ),
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                          labelText: 'Trade Name',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: tinController,
                      decoration: InputDecoration(
                          labelText: 'TIN Number',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "TIN Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: vatController,
                      decoration: InputDecoration(
                          labelText: 'VAT Number',
                          enabled: isActve,
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                      validator: (value){
                          if(value!.isEmpty){
                            return "VAT Required";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color:Colors.grey.shade600 ),
                          enabled: isActve,
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(formKey.currentState!.validate()){
                            final db = DatabaseHelper();
                            await db.addCustomer(Customer(
                              tradeName: customerNameController.text,
                              tinNumber: int.parse(tinController.text),
                              vatNumber: int.parse(vatController.text),
                              address: addressController.text,
                              email: emailController.text
                            ));
                            setState(() {
                              selectedCustomer.add({
                                'tradeName': customerNameController.text,
                                'tinNumber': tinController.text,
                                'vatNumber': vatController.text,
                                'address': addressController.text,
                                'email': emailController.text,
                              });
                            });
                            
                            Navigator.pop(context);
                            Get.snackbar(
                              'Success',
                              'Customer Details Saved',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDark,
                          padding:const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Save Customer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                
              ),
            ),
          ),
        );
      }
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
                  padding: EdgeInsets.all(8.0),
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
          padding:const  EdgeInsets.symmetric(horizontal: 5.0 , vertical: 10.0) ,
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
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("USD: \$${calculateTotalPrice().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        const SizedBox(width: 20),
                        //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        Text("QTY: ${cartItems.length}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        const SizedBox(width: 20),
                        //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                        Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
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
                    return showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: false,
                      context: context,
                      builder: (context){
                        return Container(
                          height: 600,
                          child: Padding(
                            padding:  EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: MediaQuery.of(context).viewInsets.bottom
                            ),
                            child: Form(
                              key: paidKey,
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 5,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: kDark,
                                          borderRadius: BorderRadius.circular(20), 
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        IconButton(onPressed: (){
                                          Navigator.pop(context);
                                        }, icon:const Icon(Icons.arrow_circle_left_sharp, size: 40, color: kDark,)),
                                        const Text("Customer Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),),
                                      ],
                                    ),
                                    selectedCustomer.isEmpty?
                                    const Text("Customer: Cash" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),):
                                    Text("Customer: ${ selectedCustomer[0]['tradeName']}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    const SizedBox(width: 20),
                                    Text("USD: \$${calculateTotalPrice().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    const SizedBox(width: 20),
                                    //Text("\$${calculateTotalPrice().toStringAsFixed(2)}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                    Text("Items: ${cartItems.length}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    const SizedBox(width: 20),
                                    //Text("${cartItems.length}" , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold , fontSize: 20),),
                                    Text("Tax: \$${calculateTotalTax().toStringAsFixed(2)}" , style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: kDark,
                                      ),
                                      child: ListView.builder(
                                        itemCount: cartItems.length,
                                        itemBuilder: (context , index){
                                          final product = cartItems[index];
                                          return ListTile(
                                            title: Text(product['productName'] , style: const TextStyle(color: Colors.white),),
                                            subtitle: Text("Price: \$${product['sellingPrice']} - Tax: ${product['tax'].toUpperCase()}", style: const TextStyle(color: Colors.white),),
                                            leading: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(50.0)
                                              ),
                                              child:  Center(
                                                child:  Text(
                                                  product['sellqty'].toString(),
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDark),
                                                ),
                                              ),
                              
                                            ),
                                          );
                                        }
                                      ),
                                    ),
                                    const SizedBox(height: 30,),
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Paid", style:const TextStyle(color: Colors.black , fontWeight: FontWeight.w500 , fontSize: 18),),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*'), // Allows only digits and a single decimal point
                                              ),
                                            ],
                                            controller: paidController,
                                            decoration: InputDecoration(
                                              labelText: 'Amount Paid',
                                              labelStyle: TextStyle(color:Colors.grey.shade600 ),
                                              filled: true,
                                              fillColor: Colors.grey.shade300,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                                borderSide: BorderSide.none
                                              )
                                            ),
                                            validator: (value){
                                              if(value!.isEmpty){
                                                return "Amount Required";
                                              }return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 40,),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          try {
  // Check if the text input is empty
  if (paidController.text.isEmpty) {
    Get.snackbar(
      "Alert",
      "Sales cannot complete without amount paid",
      icon: Icon(Icons.sd_card_alert),
      colorText: Colors.black,
      backgroundColor: Colors.amber,
    );
    return; // Exit the function
  }

  // Try parsing the input to a double
  double paid = double.tryParse(paidController.text) ?? 0.0;
  double price = double.parse(calculateTotalPrice().toString());

  // Validate the parsed values
  if (paid <= 0) {
    Get.snackbar(
      "Error",
      "Invalid amount paid. Please enter a valid number.",
      icon: Icon(Icons.error),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
    return; // Exit the function
  }

  // Check if the paid amount is less than the total price
  if (paid < price) {
    Get.snackbar(
      "Error",
      "Amount Paid Is Not Sufficient",
      icon: Icon(Icons.error),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
    return; // Exit the function
  }

  // Complete the sale if all validations pass
  completeSale();
  Navigator.pop(context);
} catch (e) {
  // Handle any unexpected errors
  Get.snackbar(
    "Error",
    "An error occurred: $e",
    icon: Icon(Icons.error),
    colorText: Colors.white,
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
  );
}

                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding:const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save Sale',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                              
                                  ],
                                            
                              ),
                            ),
                          ),
                        );
                      }
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