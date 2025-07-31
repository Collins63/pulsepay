import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/JsonModels/json_models.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/constants.dart';
import 'package:pulsepay/common/custom_button.dart';

class BakingDetails extends StatefulWidget {
  const BakingDetails({super.key});

  @override
  State<BakingDetails> createState() => _BakingDetailsState();
}

class _BakingDetailsState extends State<BakingDetails> {
  final formKey = GlobalKey<FormState>();
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> bankingDetails = [];
  List<int> selectedMethod = [];
  bool isLoading = true;
  final bankController = TextEditingController();
  final branchController = TextEditingController();
  final accountNameController = TextEditingController();
  final accountNoController = TextEditingController();
  final currencyController = TextEditingController();
  List<Map<String, dynamic>> bankDetailsFromID = [];

  @override
  void initState() {
    super.initState();
    fetchBankingDetails();
  }

  Future<void> fetchBankingDetails() async {
    List<Map<String, dynamic>> data = await dbHelper.getBankingDetails();
    setState(() {
      bankingDetails = data;
      isLoading = false;
    });
  }

  void toggleSelection(int bankId) {
    setState(() {
      if (selectedMethod.contains(bankId) || selectedMethod.isNotEmpty) {
        selectedMethod.remove(bankId);
        selectedMethod.clear();
      } else {
        selectedMethod.add(bankId);
      }
    });
  }

  void deleteByID() async{
    int bankID = 9999;
    bankID = selectedMethod[0];
    //String methodName = selectedMethod[1].toString();
    if(bankID != 9999){
      await  dbHelper.deleteBankingDetails(bankID);
      fetchBankingDetails();
      Get.snackbar("Delete Message", " Deleted successfully!!",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.message_outlined)
      );

    }
  }

  //========fetch products by id==================

  Future<void> fetchBankById() async{
    int productid = selectedMethod[0];
    List<Map<String, dynamic>> data = await dbHelper.getBankDetailsById(productid);
    setState(() {
      bankDetailsFromID = data;
      isLoading = false;
      updateBankingDetails();
    });
  }

  ///=====Add Paymethods=====//////////
  //////////////////////////////////////
  addBankingDetails(){
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
                        const Center(child: const Text("Banking Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: bankController,
                      decoration: InputDecoration(
                          labelText: 'Bank',
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
                          return "Field required!!";
                        } return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: branchController,
                      decoration: InputDecoration(
                          labelText: 'Bank Branch',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: accountNameController,
                      decoration: InputDecoration(
                          labelText: 'Account Name',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: accountNoController,
                      decoration: InputDecoration(
                          labelText: 'Account Number',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: currencyController,
                      decoration: InputDecoration(
                          labelText: 'Currency',
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
                          return "Field required!!";
                        }return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          try {
                            if(formKey.currentState!.validate()){
                            final db = DatabaseHelper();
                            await db.addBankingDetails(Banking(
                              bank: bankController.text.toUpperCase(),
                              bankBranch: branchController.text.toUpperCase(),
                              bankAcntName: accountNameController.text.toUpperCase(),
                              bankAcntNo: accountNoController.text.toUpperCase(),
                              currency: currencyController.text.toUpperCase()
                            ));
                            Navigator.pop(context);
                            Get.snackbar(
                              'Success',
                              'Banking Details Saved',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white
                            );
                            fetchBankingDetails();
                          }
                          } catch (e) {
                            Get.snackbar(
                              "Error Saving", "$e",
                              icon:const Icon(Icons.error),
                              colorText: Colors.white,
                              backgroundColor: Colors.red,
                              snackPosition: SnackPosition.TOP
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
                          'Save Banking Details',
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

  ///=====Update banking details=====//////////
  //////////////////////////////////////
  updateBankingDetails(){

    // final bankController = TextEditingController();
    // final branchController = TextEditingController();
    // final accountNameController = TextEditingController();
    // final accountNoController = TextEditingController();
    // final currencyController = TextEditingController();
    bankController.text = bankDetailsFromID.isNotEmpty ? bankDetailsFromID[0]['bank'].toString() : '';
    branchController.text = bankDetailsFromID.isNotEmpty ? bankDetailsFromID[0]['bankBranch'].toString() : '';
    accountNameController.text  = bankDetailsFromID.isNotEmpty ? bankDetailsFromID[0]['bankAcntName'].toString() : '';
    accountNoController.text = bankDetailsFromID.isNotEmpty ? bankDetailsFromID[0]['bankAcntNo'].toString() : '';
    currencyController.text = bankDetailsFromID.isNotEmpty ? bankDetailsFromID[0]['currency'].toString() : '';


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
                        const Center(child: const Text("Banking Details" , style: TextStyle(color: Colors.black,fontSize: 18, fontWeight: FontWeight.w500),)),
                      ],
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: bankController,
                      decoration: InputDecoration(
                          labelText: 'Bank',
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
                          return "Field required!!";
                        } return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: branchController,
                      decoration: InputDecoration(
                          labelText: 'Bank Branch',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: accountNameController,
                      decoration: InputDecoration(
                          labelText: 'Account Name',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: accountNoController,
                      decoration: InputDecoration(
                          labelText: 'Account Number',
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
                            return "Field required!!";
                          }return null;
                        },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: currencyController,
                      decoration: InputDecoration(
                          labelText: 'Currency',
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
                          return "Field required!!";
                        }return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async{
                          int bankID = selectedMethod[0];
                          try {
                            if(formKey.currentState!.validate()){
                            final db = DatabaseHelper();
                            await db.updateBankimgDetails(
                              bankID,
                              bankController.text.toUpperCase(),
                              branchController.text.toUpperCase(),
                              accountNameController.text.toUpperCase(),
                              accountNoController.text.toUpperCase(),
                              currencyController.text.toUpperCase()
                            );
                            Navigator.pop(context);
                            Get.snackbar(
                              'Success',
                              'Banking Details Updated',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white
                            );
                            fetchBankingDetails();
                          }
                          } catch (e) {
                            Get.snackbar(
                              "Error Updating", "$e",
                              icon:const Icon(Icons.error),
                              colorText: Colors.white,
                              backgroundColor: Colors.red,
                              snackPosition: SnackPosition.TOP
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
                          'Update Banking Details',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("Banking Details" , style: TextStyle(fontSize: 18, color: Colors.white, fontWeight:  FontWeight.bold),),
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
        child: SafeArea(
          child:Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25,),
                CustomOutlineBtn(text: "Add Banking Details", color: Colors.green ,color2: Colors.green, height: 50, onTap: (){addBankingDetails();},),
                const SizedBox(height: 25,),
                const Center(child: Text("Available Pay Methods" , style: TextStyle(fontWeight: FontWeight.w500),)),
                const SizedBox(height: 10,),
                isLoading? const Center(child: CircularProgressIndicator(),)
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const[
                            DataColumn(label: Text("Select")),
                            DataColumn(label: Text("Bank")),
                            DataColumn(label: Text("Branch")),
                            DataColumn(label: Text("Account Name")),
                            DataColumn(label: Text("Account Number")),
                            DataColumn(label: Text("Currency")),
                          ],
                          rows: bankingDetails.map((detail){
                            final methodId = detail['bankId'];
                            return DataRow(
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: selectedMethod.contains(methodId),
                                    onChanged: (_)=> toggleSelection(methodId),
                                  )
                                ),
                                DataCell(Text(detail['bank'].toString())),
                                DataCell(Text(detail['bankBranch'].toString())),
                                DataCell(Text(detail['bankAcntName'].toString())),
                                DataCell(Text(detail['bankAcntNo'].toString())),
                                DataCell(Text(detail['currency'].toString())),
                              ]
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                if (selectedMethod.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomOutlineBtn(
                    width: 100,
                    height: 45,
                    text: "Edit",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29),
                    onTap: (){
                      //final i = selectedUsers.first;
                      //fetchSalesForInvoice(invoiceId);;
                      fetchBankById();
                    },
                  ),
                  CustomOutlineBtn(
                    width: 100,
                    height: 45,
                    text: "Delete",
                    color:const Color.fromARGB(255, 14, 19, 29),
                    color2: const Color.fromARGB(255, 14, 19, 29) ,
                    onTap: () {
                      deleteByID();
                    },
                  ),
                ],
              ),
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}