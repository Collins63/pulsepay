// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);

import 'package:flutter/material.dart';
//import 'package:meta/meta.dart';
import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? userId;
  final String userName;
  final String userPassword;

  Users({
    this.userId,
    required this.userName,
    required this.userPassword,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    userId: json["userID"],
    userName: json["userName"],
    userPassword: json["userPassword"],
  );

  Map<String, dynamic> toMap() => {
    "userID": userId,
    "userName": userName,
    "userPassword": userPassword,
  };
}

// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);


Products productsFromMap(String str) => Products.fromMap(json.decode(str));

String productsToMap(Products data) => json.encode(data.toMap());

class Products {
  final int? productid;
  final String productName;
  final String barcode;
  final double costPrice;
  final double sellingPrice;
  final String tax;

  Products({
    this.productid,
    required this.productName,
    required this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.tax
  });

  factory Products.fromMap(Map<String, dynamic> json) => Products(
    productid: json["productid"],
    productName: json["productName"],
    barcode: json["barcode"],
    costPrice: json["costPrice"],
    sellingPrice: json["sellingPrice"],
    tax: json['tax']
  );

  Map<String, dynamic> toMap() => {
    "productid": productid,
    "productName": productName,
    "barcode": barcode,
    "costPrice": costPrice,
    "sellingPrice": sellingPrice,
    "tax": tax
  };
}

// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);


Invoices invoicesFromMap(String str) => Invoices.fromMap(json.decode(str));

String invoicesToMap(Invoices data) => json.encode(data.toMap());

class Invoices {
  final int? invoiceId;
  final Text date;
  final double totalAmount;
  final double totalTax;

  Invoices({
    this.invoiceId,
    required this.date,
    required this.totalAmount,
    required this.totalTax,
  });

  factory Invoices.fromMap(Map<String, dynamic> json) => Invoices(
    invoiceId: json["invoiceId"],
    date: json["date"],
    totalAmount: json["totalAmount"],
    totalTax: json["totalTax"],
  );

  Map<String, dynamic> toMap() => {
    "invoiceId": invoiceId,
    "date": date,
    "totalAmount": totalAmount,
    "totalTax": totalTax,
  };
}


// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);


Sales salesFromMap(String str) => Sales.fromMap(json.decode(str));

String salesToMap(Sales data) => json.encode(data.toMap());

class Sales {
  final int? saleId;
  final int invoiceId;
  final int productId;
  final int quantity;
  final double sellingPrice;
  final double tax;

  Sales({
    this.saleId,
    required this.invoiceId,
    required this.productId,
    required this.quantity,
    required this.sellingPrice,
    required this.tax
  });

  factory Sales.fromMap(Map<String, dynamic> json) => Sales(
    saleId: json["salesId"],
    invoiceId: json["invoiceId"],
    productId: json["productId"],
    quantity: json["quantity"],
    sellingPrice: json["sellingPrice"],
    tax: json["tax"]
  );

  Map<String, dynamic> toMap() => {
    "salesId": saleId,
    "invoiceId": invoiceId,
    "productId": productId,
    "quantity": quantity,
    "sellingPrice":sellingPrice,
    "tax":tax,
  };
}