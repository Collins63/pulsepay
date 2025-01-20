// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);

import 'dart:ffi';

import 'package:flutter/material.dart';
//import 'package:meta/meta.dart';
import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? userId;
  final String? realName;
  final String userName;
  final String userPassword;
  final String? dateCreated;
  final int? isAdmin;
  final int? isCashier;
  final int? isActive;


  Users({
    this.userId,
    this.realName,
    required this.userName,
    required this.userPassword,
    this.dateCreated,
    this.isAdmin,
    this.isCashier,
    this.isActive
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    userId: json["userID"],
    realName: json["realName"],
    userName: json["userName"],
    userPassword: json["userPassword"],
    dateCreated: json["dateCreated"],
    isAdmin: json["isAdmin"],
    isCashier: json["isCashier"],
    isActive: json["isActive"]
  );

  Map<String, dynamic> toMap() => {
    "userID": userId,
    "realName": realName,
    "userName": userName,
    "userPassword": userPassword,
    "dateCreated": dateCreated,
    "isAdmin": isAdmin,
    "isCashier": isCashier,
    "isActive": isActive
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
  final int hsCode;
  final double costPrice;
  final double sellingPrice;
  final String tax;
  final int stockQty;

  Products({
    this.productid,
    required this.productName,
    required this.barcode,
    required this.hsCode,
    required this.costPrice,
    required this.sellingPrice,
    required this.tax,
    required this.stockQty
  });

  factory Products.fromMap(Map<String, dynamic> json) => Products(
    productid: json["productid"],
    productName: json["productName"],
    barcode: json["barcode"],
    hsCode: json["hsCode"],
    costPrice: json["costPrice"],
    sellingPrice: json["sellingPrice"],
    tax: json["tax"],
    stockQty: json["stockQty"]
  );

  Map<String, dynamic> toMap() => {
    "productid": productid,
    "productName": productName,
    "barcode": barcode,
    "hsCode": hsCode,
    "costPrice": costPrice,
    "sellingPrice": sellingPrice,
    "tax": tax,
    "stockQty": stockQty
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
  final int? customerID;
  final int productId;
  final int quantity;
  final double sellingPrice;
  final double tax;

  Sales({
    this.saleId,
    required this.invoiceId,
    this.customerID,
    required this.productId,
    required this.quantity,
    required this.sellingPrice,
    required this.tax
  });

  factory Sales.fromMap(Map<String, dynamic> json) => Sales(
    saleId: json["salesId"],
    invoiceId: json["invoiceId"],
    customerID: json["customerID"],
    productId: json["productId"],
    quantity: json["quantity"],
    sellingPrice: json["sellingPrice"],
    tax: json["tax"]
  );

  Map<String, dynamic> toMap() => {
    "salesId": saleId,
    "invoiceId": invoiceId,
    "customerID": customerID,
    "productId": productId,
    "quantity": quantity,
    "sellingPrice":sellingPrice,
    "tax":tax,
  };
}


///CustomerDetailsModel//////
///////////////////////////////////////////////////////
Customer customerFromMap(String str) => Customer.fromMap(json.decode(str));

String customerToMap(Customer data) => json.encode(data.toMap());

class Customer {
  final int? customerID;
  final String tradeName;
  final int tinNumber;
  final int vatNumber;
  final String address;
  final String email;

  Customer({
    this.customerID,
    required this.tradeName,
    required this.tinNumber,
    required this.vatNumber,
    required this.address,
    required this.email
  });

  factory Customer.fromMap(Map<String, dynamic> json) => Customer(
    customerID: json["customerID"],
    tradeName: json["tradeName"],
    tinNumber: json["tinNumber"],
    vatNumber: json["vatNumber"],
    address: json["address"],
    email: json["email"]
  );

  Map<String, dynamic> toMap() => {
    "customerID": customerID,
    "tradeName": tradeName,
    "tinNumber": tinNumber,
    "vatNumber": vatNumber,
    "address": address,
    "email": email,
  };
}

///CustomerDetailsModel//////
///////////////////////////////////////////////////////
StockPurchase stockPurchaseFromMap(String str) => StockPurchase.fromMap(json.decode(str));

String stockPurchaseToMap(Customer data) => json.encode(data.toMap());

class StockPurchase {
  final int? purchaseId;
  final String date;
  final int productid;
  final int quantity;
  final String payMethod;
  final String supplier;

  StockPurchase({
    this.purchaseId,
    required this.date,
    required this.productid,
    required this.quantity,
    required this.payMethod,
    required this.supplier
  });

  factory StockPurchase.fromMap(Map<String, dynamic> json) => StockPurchase(
    purchaseId: json["purchaseId"],
    date: json["date"],
    productid: json["productid"],
    quantity: json["quantity"],
    payMethod: json["payMethod"],
    supplier: json["supplier"]
  );

  Map<String, dynamic> toMap() => {
    "purchaseId": purchaseId,
    "date": date,
    "productid": productid,
    "quantity": quantity,
    "payMethod": payMethod,
    "supplier": supplier,
  };
}


///CustomerDetailsModel//////
///////////////////////////////////////////////////////
PaymentMethod paymentMethodFromMap(String str) => PaymentMethod.fromMap(json.decode(str));

String paymentMethodToMap(Customer data) => json.encode(data.toMap());

class PaymentMethod{
  final int? payMethodId;
  final String description;
  final double rate;
  final int fiscalGroup;
  final String currency;
  final String? vatNumber;
  final String? tinNumber;

  PaymentMethod({
    this.payMethodId,
    required this.description,
    required this.rate,
    required this.fiscalGroup,
    required this.currency,
    this.vatNumber,
    this.tinNumber
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> json) => PaymentMethod(
    payMethodId: json["payMethodId"],
    description: json["description"],
    rate: json["rate"],
    fiscalGroup: json["fiscalGroup"],
    currency: json["currency"],
    vatNumber: json["vatNumber"],
    tinNumber: json["tinNumber"]
  );

  Map<String, dynamic> toMap() => {
    "payMethodId": payMethodId,
    "description": description,
    "rate": rate,
    "fiscalGroup": fiscalGroup,
    "currency": currency,
    "vatNumber": vatNumber,
    "tinNumber": tinNumber
  };
}