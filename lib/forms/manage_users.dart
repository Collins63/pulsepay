import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsepay/SQLite/database_helper.dart';
import 'package:pulsepay/common/custom_button.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});
  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = [];
  List<int> selectedUsers = [];
  bool isLoading = true;
  List<Map<String, dynamic>> userFromID = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchuSERById(int userId) async{
    List<Map<String, dynamic>> data = await dbHelper.getUserById(userId);
    setState(() {
      userFromID = data;
      isLoading = false;
      showUpdatePrompt();
    });
  }

  Future<void> deactivateuser(int userId) async{
    try {
      await dbHelper.deactivateUser(userId);
      Get.snackbar(
        "Succes", 
        "User Deactivated",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check ,color: Colors.white,)
      );
    } catch (e) {
      Get.snackbar(
        "Deactivation error", 
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error ,color: Colors.white,)
      );
    }
  }

  showUpdatePrompt(){
    final TextEditingController realName  = TextEditingController();
    final TextEditingController userName = TextEditingController();
    final TextEditingController userPassword = TextEditingController();
    final TextEditingController isadmin = TextEditingController();
    final TextEditingController iscashier = TextEditingController();

    realName.text = userFromID.isNotEmpty ? userFromID[0]['realName'].toString() : '';
    userName.text = userFromID.isNotEmpty ? userFromID[0]['userName'].toString() : '';
    userPassword.text = userFromID.isNotEmpty ? userFromID[0]['userPassword'].toString() : '';
    isadmin.text = userFromID.isNotEmpty ? userFromID[0]['isAdmin'].toString() : '';
    iscashier.text = userFromID.isNotEmpty ? userFromID[0]['isCashier'].toString() : '';
    int userId = userFromID.isNotEmpty ? userFromID[0]['userId'] : 0;

    showDialog(
      context: context,
      barrierDismissible:  false,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Update Product"),
          content:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Type In Fields To Update Product"),
              const SizedBox(height: 10,),
              TextField(
                controller: realName,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Real Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: userName,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: userPassword,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'User password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: isadmin,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Is Admin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: iscashier,
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: 'Is Cashier',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10,),
            ],
          ) ,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
            onPressed: () {
              String name = realName.text;
              String username = userName.text;
              String password = userPassword.text;
              int isAdmin = int.tryParse(isadmin.text)!;
              int isCashier = int.tryParse(iscashier.text)!;
              dbHelper.updateUser(userId, name, username, password, isAdmin, isCashier).then((_) {
                Navigator.of(context).pop(); // Close the dialog
                fetchUsers();// Refresh the product list
                Get.snackbar(
                  'User Update', 'User Updated Successfully',
                  snackPosition: SnackPosition.TOP,
                  colorText: Colors.white,
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.message, color: Colors.white),
                );
              });
            },
            child: const Text('Update'),
          ),
          ],
        );
      }
    );

  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> data = await dbHelper.getAllUsers();
    setState(() {
      users = data;
      isLoading = false;
    });
  }

  void toggleSelection(int userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.clear();
        selectedUsers.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50)
        ,child: AppBar(
          centerTitle: true,
          title: const Text("Manager Users" , style: TextStyle(fontSize: 20, color: Colors.white, fontWeight:  FontWeight.bold),),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        headingRowColor: MaterialStateProperty.all(Colors.blue),
                        columns: const [
                          DataColumn(label: Text('Real Name')),
                          DataColumn(label: Text('Username')),
                          DataColumn(label: Text('DateCreated')),
                          DataColumn(label: Text('IsActive')),
                          DataColumn(label: Text('IsAdmin')),
                          DataColumn(label: Text('IsCashier')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: users
                            .map(
                              (user) {
                                final userId = user['userId'];
                                return DataRow(
                                  selected: selectedUsers.contains(userId),
                                  onSelectChanged: (selected) {
                                    toggleSelection(userId);
                                  },
                                cells: [
                                  DataCell(Text(user['realName'].toString())),
                                  DataCell(Text(user['userName'].toString())),
                                  DataCell(Text(user['dateCreated'].toString())),
                                  DataCell(Text(user['isActive'].toString())),
                                  DataCell(Text(user['isAdmin'].toString())),
                                  DataCell(Text(user['isCashier'].toString())),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                             fetchuSERById(userId);
                                          },
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title:  const Text("De-Activate Confirmation"),
                                                  content:const Column(
                                                    mainAxisSize: MainAxisSize.min ,
                                                    children: [
                                                      Center(child: Text("Are you sure!!")),
                                                      SizedBox(height: 10,),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      await deactivateuser(userId);
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('De-Activate'),
                                                  ),
                                                  ],
                                                );
                                              }
                                            );
                                          }, 
                                          icon: const Icon(Icons.remove_circle, color: Colors.red)
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title:  const Text("Confirm Deletion"),
                                                  content:const Column(
                                                    mainAxisSize: MainAxisSize.min ,
                                                    children: [
                                                      Text("Are you sure you want to delete this user?"),
                                                      SizedBox(height: 10,),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      try {
                                                        await dbHelper.deleteUsers(userId);
                                                        Get.snackbar(
                                                          "Delete Success",
                                                          "User deleted Sucessfully",
                                                          snackPosition: SnackPosition.TOP,
                                                          colorText: Colors.white,
                                                          backgroundColor: Colors.green,
                                                          icon: const Icon(Icons.check, color: Colors.white,)
                                                        );
                                                        fetchUsers();
                                                      } catch (e) {
                                                        Get.snackbar(
                                                          "Delete Error",
                                                          "$e",
                                                          snackPosition: SnackPosition.TOP,
                                                          colorText: Colors.white,
                                                          backgroundColor: Colors.red,
                                                          icon: const Icon(Icons.error, color: Colors.white,)
                                                        );
                                                      }
                                                      Navigator.of(context).pop(); // Close the dialog   
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                  ],
                                                );
                                              }
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
              ],
            ),
          ),

    );
  }
}
