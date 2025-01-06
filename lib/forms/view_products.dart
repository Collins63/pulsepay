import 'package:flutter/material.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts ({super.key});

  @override
  State<ViewProducts> createState() => _ViewproductsState();
}

class _ViewproductsState extends State<ViewProducts>{
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(
        child: Text('Products' , style: TextStyle(fontSize: 24 , fontWeight: FontWeight.bold),),
      ),
    );
  }
}