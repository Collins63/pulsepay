import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulsepay/common/app_bar.dart';
import 'package:pulsepay/common/custom_button.dart';
import 'package:pulsepay/home/home_page.dart';

class Users extends StatelessWidget{
  const Users({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: CustomAppBar(
          text: "User Management",
          child: GestureDetector(
            onTap: (){
              Navigator.push(context,
               MaterialPageRoute(builder: (context) => const HomePage()));
            },
            child: const Icon(CupertinoIcons.arrow_left),
          )
        )
      ),
      body:  SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              CustomOutlineBtn(
                text:"Manage Permissions",
                color: const Color.fromARGB(255, 14, 19, 29),
                color2:const Color.fromARGB(255, 14, 19, 29) ,
                onTap: (){
          
                },
                height: 50,
              ),
              const SizedBox(height: 20,),
              CustomOutlineBtn(
                text:"Manage Users",
                color: const Color.fromARGB(255, 14, 19, 29),
                color2:const Color.fromARGB(255, 14, 19, 29) ,
                onTap: (){
          
                },
                height: 50,
              ),
              const SizedBox(height: 20,),
              CustomOutlineBtn(
                text:"Add User",
                color: const Color.fromARGB(255, 14, 19, 29),
                color2:const Color.fromARGB(255, 14, 19, 29) ,
                onTap: (){
          
                },
                height: 50,
              ),
              const SizedBox(height: 20,),
              CustomOutlineBtn(
                text:"Assign Roles",
                color: const Color.fromARGB(255, 14, 19, 29),
                color2:const Color.fromARGB(255, 14, 19, 29) ,
                onTap: (){
          
                },
                height: 50,
              )
            ],
          ),
        )),
        bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){

                },
                icon: const Column(
                  children: [
                    Icon(Icons.home, color: Colors.black,),
                    Text(
                        "Home",
                        style: TextStyle(fontSize: 10),
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
                  Icon(Icons.list_alt, color: Colors.grey),
                  Text(
                    "Products",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            FloatingActionButton(
                onPressed: (){
                 // Navigator.pushReplacement(
                   // context,
                   // MaterialPageRoute(builder: (context) => const Apply()),
                  //);
                },
                backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.calculate,
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
                  Icon(Icons.summarize, color: Colors.grey),
                  Text(
                    "Reporting",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: (){
               // Navigator.pushReplacement(
                 // context,
                 // MaterialPageRoute(builder: (context) => Profile()),
               // );
              },
              icon: const Column(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  Text(
                    "Settings",
                    style: TextStyle(fontSize: 10),
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
