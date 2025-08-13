import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pulsepay/JsonModels/json_models.dart';

class DatabaseHelper {
  final databaseName = "pulse.db";

  /////=========TABLES=========//////////
  ///
  

  String dailyReports=
    "create table dailyReports(ID INTEGER PRIMARY KEY AUTOINCREMENT, reportDate TEXT , reportTime TEXT , FiscalDayNo INTEGER , SaleByTaxUSD REAL , SaleByTaxZWG REAL , SaleTaxByTaxUSD REAL , SaleTaxByTaxZWG REAL , CreditNoteByTaxUSD REAL , CreditNoteByTaxZWG REAL , CreditNoteTaxByTaxUSD REAL , CreditNoteTaxByTaxZWG REAL, BalanceByMoneyTypeCashUSD REAL , BalanceByMoneyTypeCashZWG REAL , BalanceByMoneyTypeCardUSD REAL , BalanceByMoneyTypeCardZWG REAL , BalanceByMoneyTypeMobileWalletUSD REAl , BalanceByMoneyTypeMobileWalletZWG REAL , BalanceByMoneyTypeCouponUSD REAL , BalanceByMoneyTypeCouponZWG REAL , BalanceByMoneyTypeInvoiceUSD REAL , BalanceByMoneyTypeInvoiceZWG REAL , BalanceByMoneyTypeBankTransferUSD REAL , BalanceByMoneyTypeBankTransferZWG REAL , BalanceByMoneyTypeOtherUSD REAL ,BalanceByMoneyTypeOtherZWG REAL ,reportHash TEXT , reportSignature TEXT , reportJsonBody TEXT , fiscalDayStatus TEXT)";
  
  String openDay= 
   "create table openDay(ID INTEGER PRIMARY KEY AUTOINCREMENT , FiscalDayNo INTEGER , StatusOfFirstReceipt TEXT , FiscalDayOpened TEXT , FiscalDayClosed TEXT , TaxExempt INTEGER , TaxZero INTEGER , Tax15 INTEGER , TaxWT INTEGER )";

  String submittedReceipts=
   "create table submittedReceipts(receiptGlobalNo INTEGER PRIMARY KEY AUTOINCREMENT , receiptCounter INTEGER ,  FiscalDayNo INTEGER , InvoiceNo INTEGER , receiptID INTEGER , receiptType TEXT , receiptCurrency TEXT , moneyType TEXT , receiptDate TEXT , receiptTime TEXT , receiptTotal REAL , taxCode TEXT , taxPercent TEXT , taxAmount REAL , SalesAmountwithTax REAL, receiptHash TEXT , receiptJsonbody TEXT , StatustoFDMS TEXT , qrurl TEXT , receiptServerSignature TEXT , submitReceiptServerresponseJSON TEXT, Total15VAT REAL , TotalNonVAT REAL , TotalExempt REAL , TotalWT REAL  )";

  String users = 
    "create table users(userId INTEGER PRIMARY KEY AUTOINCREMENT,realName TEXT , userName TEXT UNIQUE , userPassword TEXT , dateCreated TEXT , isAdmin INTEGER DEFAULT 0 ,isCashier INTEGER DEFAULT 0 , isActive INTEGER DEFAULT 1)";
  
  String products =
    "create table products(productid INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT UNIQUE , barcode TEXT,hsCode INTEGER , costPrice REAL , sellingPrice REAL , sellqty REAL , tax TEXT , sellTax REAL ,stockQty INTEGER DEFAULT 0)";


  String invoices =
    "create table invoices (invoiceId INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,totalAmount REAL,totalTax REAL , currency TEXT , rate REAL, doneBY TEXT NOT NULL DEFAULT Cashier ,cancelled INTEGER NOT NULL DEFAULT 0)";

  String stockPurchases =
    "create table stockPurchases ( purchaseId INTEGER PRIMARY KEY AUTOINCREMENT , date TEXT , productid INTEGER , quantity INTEGER , payMethod TEXT, supplier TEXT ,FOREIGN KEY(productid) REFERENCES products(productid))";

  String sales = 
    "CREATE TABLE sales (saleId INTEGER PRIMARY KEY AUTOINCREMENT,invoiceId INTEGER,customerID INTEGER,productId INTEGER,quantity INTEGER,sellingPrice REAL,tax REAL , currency TEXT , rate REAL,doneBY TEXT NOT NULL DEFAULT Cashier ,FOREIGN KEY(invoiceId) REFERENCES invoices(invoiceId),FOREIGN KEY(productId) REFERENCES products(productid), FOREIGN KEY(customerID) REFERENCES customers(customerID) )";
  
  String customers =
    "CREATE TABLE customer(customerID INTEGER PRIMARY KEY AUTOINCREMENT , tradeName TEXT , tinNumber INTEGER , vatNumber INTEGER , address TEXT , email TEXT , isFiscal INTEGER DEFAULT 0 )";
  // vat zero ex

  String companyDetails =
    "create table companyDetails(companyID INTEGER PRIMARY KEY AUTOINCREMENT , company TEXT , logo TEXT , address TEXT , tel TEXT , branchName TEXT , tel2 TEXT , email TEXT , tinNumber TEXT, vatNumber TEXT ,vendorNumber TEXT , website TEXT , baseCurreny TEXT , backUpLocation TEXT , baseTaxPercentage REAL)";
  
  String paymentMethods =
    "create table paymentMethods (payMethodId INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT , rate REAL , fiscalGroup INTEGER , currency TEXT , vatNumber TEXT , tinNumber TEXT , defaultMethod INTEGER DEFAULT 0 )";

  String receiptAnomallies = "create table receiptAnomallies (anomallyId INTEGER PRIMARY KEY AUTOINCREMENT , receiptGlobalNo INTEGER ,isAnomaly INTEGER , score REAL , receiptTotal REAL , taxAmount REAL , salesAmountWithTax REAL , taxPercent TEXT)";
   
  String quotations = "create table quotations(quotationID INTEGER PRIMARY KEY AUTOINCREMENT , productId INTEGER , productDescription TEXT , quantity REAL , unitCost REAL, sellingPrice REAL , taxAmount REAL , customerID TEXT , date TEXT , paymentMethod TEXT , quotationReference TEXT , qoutationNumber TEXT ,FOREIGN KEY(quotationReference) REFERENCES quotationInvoice(quotationReference),FOREIGN KEY(productId) REFERENCES products(productid), FOREIGN KEY(customerID) REFERENCES customers(customerID) )";

  String quotationInvoice = "create table quotationInvoice(quotationInvoiceID INTEGER PRIMARY KEY AUTOINCREMENT , quantity REAL , totalCost REAL, sellingPrice REAL , taxAmount REAL , customerID TEXT , date TEXT , paymentMethod TEXT , quotationReference TEXT , qoutationNumber TEXT )";

  String shifts = "create table shifts(shiftId INTEGER PRIMARY KEY AUTOINCREMENT, shiftDescription TEXT , startTime TEXT, endTime TEXT , open INTEGER, userID Text , shiftTotal REAL)";

  String discounts = "create table discounts(discountId INTEGER PRIMARY KEY AUTOINCREMENT , productId INTEGER , discountAmount REAL , ogPrice REAL , doneBy TEXT , doneWhen TEXT , quantity REAL , invoiceNumber INTEGER , currency TEXT, rate REAL)";

  String bankingDetails = "create table banks( bankId INTEGER PRIMARY KEY AUTOINCREMENT ,bank TEXT ,bankBranch TEXT , bankAcntName TEXT , bankAcntNo TEXT, currency TEXT )";

  String creditNotes = "create table credit_notes (id INTEGER PRIMARY KEY AUTOINCREMENT,receiptGlobalNo TEXT,receiptID TEXT,receiptDate TEXT,receiptTotal REAL,receiptNotes TEXT,creditNoteNumber TEXT)";

   String taxPayerDetails =
    "create table taxPayerDetails (taxPayerId INTEGER PRIMARY KEY AUTOINCREMENT, taxPayerName TEXT , taxPayerTin TEXT , taxPayerVatNumber TEXT ,deviceID int, activationKey TEXT, deviceModelName TEXT , serialNo TEXT , deviceModelVersion TEXT)";

  //====DATABASE FUNCTIONS =======/////////
Future<void> deleteDB() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, databaseName);
  await deleteDatabase(path);
}


  Future<Database> initDB() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, databaseName);

  return openDatabase(
    path,
    version: 1, // ✅ bumped version
    onCreate: (db, version) async {
      // ✅ Tables created for new installs
      await db.execute(users);
      await db.execute(products);
      await db.execute(invoices);
      await db.execute(sales);
      await db.execute(customers);
      await db.execute(stockPurchases);
      await db.execute(companyDetails);
      await db.execute(paymentMethods);
      await db.execute(openDay);
      await db.execute(submittedReceipts);
      await db.execute(receiptAnomallies);
      await db.execute(quotations);
      await db.execute(shifts);
      await db.execute(discounts);
      await db.execute(bankingDetails);
      await db.execute(creditNotes);
      await db.execute(taxPayerDetails);
      await db.execute(quotationInvoice);
      // await db.execute(dailyReports); // add when needed
    },
    // onUpgrade: (db, oldVersion, newVersion) async {
      
    // },
  );
}


  Future<bool> login(Users user) async{
    final Database db = await initDB();
    var result = await db.rawQuery("select * from users where userName = '${user.userName}' AND userPassword='${user.userPassword}' ");
    if (result.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }
   // Fetch sales data for reports
  Future<List<Map<String, dynamic>>> getSalesReport(String period) async {
    final db = await initDB();
    String query = "";

    if (period == "Daily") {
      query = "SELECT totalAmount, strftime('%Y-%m-%d', date) as date FROM invoices GROUP BY date";
    } else if (period == "Weekly") {
      query = "SELECT totalAmount, strftime('%Y-%W', date) as date FROM invoices GROUP BY date";
    } else if (period == "Monthly") {
      query = "SELECT totalAmount, strftime('%Y-%m', date) as date FROM invoices GROUP BY date";
    }
    return await db.rawQuery(query);
  }
  //signup
  Future<int> signup(Users user)async{
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  Future<int> insertReceipt(SubmittedReceipt receiptData) async {
    final db = await initDB();
    return await db.insert('submittedReceipts', receiptData.toMap());
    }

  Future<int> addReceipt(SubmittedReceipt receipt) async{
    final Database db = await initDB();
    return db.insert('submittedReceipts', receipt.toMap());
  }
  //add products
  Future<int> addProduct(Products product) async{
    final Database db = await initDB();
    return db.insert('products', product.toMap());
  }

  //add company details
  Future<int> addCompanyDetails(CompanyDetails companyDetails) async{
    final Database db = await initDB();
    return db.insert('companyDetails', companyDetails.toMap());
  }

  //add taxPayer details
  Future<int> addTaxPayerDetails(TaxPayer taxPayerDetails) async{
    final Database db = await initDB();
    return db.insert('taxPayerDetails', taxPayerDetails.toMap());
  }

  //add payment methods
  Future<int> addPayMethod(PaymentMethod paymentMethod) async{
    final Database db = await initDB();
    return db.insert('paymentMethods', paymentMethod.toMap());
  }

  //add banking details
  Future<int> addBankingDetails(Banking bankingDetails) async{
    final Database db = await initDB();
    return db.insert('banks', bankingDetails.toMap());
  }

  //Add Stock Purchase
  Future<int> addStockPurchase(StockPurchase stockPurchase) async{
    final Database db = await initDB();
    return db.insert('stockPurchases', stockPurchase.toMap());
  }

  //Add Customer 

  Future<int> addCustomer(Customer customer) async{
    final Database db = await initDB();
    return db.insert('customer', customer.toMap());
  }

  //search for customer
  Future<List<Map<String, dynamic>>> searchCustomer(String query) async {
    final Database db = await initDB();
    return db.query(
      'customer',
      where: 'tradeName LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  //search for products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final Database db = await initDB();
    return db.query(
      'products',
      where: 'productName LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  //Get product sales
  Future<List<Map<String, dynamic>>> getProductSales(int productId) async {
    final db = await initDB();
    return await db.rawQuery('''
      SELECT sales.*, invoices.date
      FROM sales
      INNER JOIN invoices ON sales.invoiceId = invoices.invoiceId
      WHERE sales.productId = ?
    ''', [productId]);
  }

  //invoice numbers
  Future<int> getNextInvoiceId() async {
    final db = await initDB();
    final result = await db.rawQuery('SELECT MAX(invoiceId) as lastId FROM invoices');
    int lastId = result.first['lastId'] as int? ?? 0; // Start at 0 if no invoices
    return lastId + 1;
  }

//get next quotation number
  Future<int> getNextQuotationId() async {
    final db = await initDB();
    final result = await db.rawQuery('SELECT MAX(invoiceId) as lastId FROM invoices');
    int lastId = result.first['lastId'] as int? ?? 0; // Start at 0 if no invoices
    return lastId + 1;
  }

  Future<int> getNextCustomerID() async{
    final db = await initDB();
    final result = await db.rawQuery('SELECT MAX(customerID) as lastId FROM customer');
    int lastId = result.first['lastId'] as int? ?? 0; // Start at 0 if no customers
    return lastId + 1;
  }
  
  Future<int> getNextReceiptGlobalNo() async {
    final db = await initDB();
    final result = await db.rawQuery('SELECT MAX(receiptGlobalNo) as lastGlobalNo FROM submittedReceipts');
    int lastGlobalNo = result.first['lastGlobalNo'] as int? ?? 0; // Start at 0 if no invoices
    return lastGlobalNo + 1;
  }

  //save sale
  Future<void> saveSale(List<Map<String, dynamic>> cartItems, double totalAmount, double totalTax , double indiTax , int customerID, String saleCurrency , String doneBY, double rate) async {
  final db = await initDB();
  final int invoiceId = await getNextInvoiceId();
  final String date = DateTime.now().toIso8601String();

  // Start a transaction
  await db.transaction((txn) async {
    // Insert into invoices table
    await txn.insert('invoices', {
      'invoiceId': invoiceId,
      'date': date,
      'totalAmount': totalAmount,
      'totalTax': totalTax,
      'currency': saleCurrency,
      'doneBY' : doneBY,
      'rate' : rate
    });

    // Insert into sales table
    for (var item in cartItems) {
      await txn.insert('sales', {
        'invoiceId': invoiceId,
        'customerID': customerID,
        'productId': item['productid'],
        'quantity': item['sellqty'],
        'sellingPrice': item['sellingPrice'],
        'currency' : saleCurrency,
        'rate': rate,
        'tax': indiTax,
        'doneBY' : doneBY // Calculate per-item tax if necessary
      });
    }
  });
}

//get next quotation number
  Future<String> getNextQuoteNumber() async {
  final db = await initDB();

  // Correct query: extract the numeric part after 'cr' and get the max as an INTEGER
  final result = await db.rawQuery(
    '''
    SELECT MAX(CAST(SUBSTR(qoutationNumber, 3) AS INTEGER)) AS maxQt
    FROM quotations
    '''
  );

  final maxQt = result.first['maxQt'] as int?;
  final nextNumber = (maxQt ?? 0) + 1;

  return 'Qt$nextNumber';
}

//save quotation
Future<void> saveQuotation(List<Map<String, dynamic>> cartItems, double totalAmount, double totalTax , double indiTax , int customerID, String saleCurrency , String doneBY) async {
  final db = await initDB();
  final String qoutationNumber = await getNextQuoteNumber();
  final String date = DateTime.now().toIso8601String();

  await db.transaction((txn) async {
    for(var item in cartItems){
      await txn.insert('quotations', {
        'invoiceId': '',
        'customerID': customerID,
        'productId': item['productid'],
        'quantity': item['sellqty'],
        'sellingPrice': item['sellingPrice'],
        'currency' : saleCurrency,
        'tax': indiTax,
        'doneBY' : doneBY // Calculate per-item tax if necessary
      });
    }
  });
}


//Get all sales
    Future<List<Map<String, dynamic>>> getAllSales() async {
      final db = await initDB();
      final query = '''
        SELECT 
        invoices.invoiceId,
        invoices.date,
        products.productName,
        sales.quantity,
        sales.sellingPrice,
        (sales.quantity * sales.sellingPrice) AS totalPrice,
        sales.tax
        FROM sales
        INNER JOIN invoices ON sales.invoiceId = invoices.invoiceId
        INNER JOIN products ON sales.productId = products.productid
        ORDER BY invoices.date DESC
        ''';

        return await db.rawQuery(query);
      }

      //Get all invoices
      Future<List<Map<String, dynamic>>> getAllInvoices() async {
        final db = await initDB();
        final query = '''
          SELECT 
          invoices.invoiceId,
          invoices.date,
          COUNT(sales.productId) AS totalItems,
          SUM(sales.quantity * sales.sellingPrice) AS totalPrice,
          SUM(sales.tax) AS totalTax
          FROM invoices
          INNER JOIN sales ON invoices.invoiceId = sales.invoiceId
          GROUP BY invoices.invoiceId
          ORDER BY invoices.date DESC
          ''';
      return await db.rawQuery(query);
      }
    

    ///Search Invoices By Invoice Number
    Future<List<Map<String, dynamic>>> searchInvoicesByNumber(String invoiceNumber) async {
      final db = await initDB();
      final query = '''
        SELECT 
        invoices.invoiceId,
        invoices.date,
        COUNT(sales.productId) AS totalItems,
        SUM(sales.quantity * sales.sellingPrice) AS totalPrice
        FROM invoices
        INNER JOIN sales ON invoices.invoiceId = sales.invoiceId
        WHERE invoices.invoiceId LIKE ?
        GROUP BY invoices.invoiceId
        ''';

      return await db.rawQuery(query, ['%$invoiceNumber%']);
    }
    
    Future<void> setActiveUser(String username) async{
      final db = await initDB();
      await db.update(
        'users',
        {'isActive': 1},
        where: 'userName = ?',
        whereArgs: [username],
      );
    }

    ///Cancel Invoice
    Future<void> cancelInvoice(int invoiceId) async {
      final db = await initDB();
      await db.transaction((txn)async{
        // Step 1: Mark invoice as cancelled
        await txn.update(
          'invoices',
          { 'cancelled': 1 },
          where: 'invoiceId = ?',
          whereArgs: [invoiceId],
        );
        // Step 2: Get sales data for this invoice
        final salesRows = await txn.query(
          'sales',
          where: 'invoiceId = ?',
          whereArgs: [invoiceId],
        );
        // Step 3: Restore stock for each product sold
        for (var sale in salesRows) {
          final productId = sale['productId'] as int;
          final quantitySold = sale['quantity'] as int;

          await db.rawUpdate('''
            UPDATE products
            SET stockQty = stockQty + ?
            WHERE productid = ?
          ''', [quantitySold, productId]);
        }
        // Step 4: Delete the sales records
        await db.delete(
          'sales',
          where: 'invoiceId = ?',
          whereArgs: [invoiceId],
        );
      });
    }

    Future<void> deactivateUser(int userID) async{
      final db= await initDB();
      await db.update(
        'users',
        { 'isActive': 0 },
        where: 'userId = ?',
        whereArgs: [userID],
      );
    }

    //Delete Paymenth method
    Future<void> deletePayMethod(int methodId) async{
      final db = await initDB();
      await db.delete(
        'paymentMethods',
        where: 'payMethodId = ?',
        whereArgs: [methodId],
      );
    }

    //Delete Users
    Future<void> deleteUsers(int userId) async{
      final db = await initDB();
      await db.delete(
        'users',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    }

    //Delete Paymenth method
    Future<void> deleteBankingDetails(int bankId) async{
      final db = await initDB();
      await db.delete(
        'banks',
        where: 'bankId = ?',
        whereArgs: [bankId],
      );
     }


    //delete product
     Future<void> deleteProduct(int productID) async{
      final db = await initDB();
      await db.delete(
        'products',
        where: 'productid = ?',
        whereArgs: [productID],
      );
     }


    ////Get Sales By Invoice
    Future<List<Map<String, dynamic>>> getSalesByInvoice(int invoiceId) async {
      final db = await initDB(); // Initialize the database
        return await db.rawQuery('''
          SELECT sales.*, products.productName 
          FROM sales
          INNER JOIN products ON sales.productId = products.productId
          WHERE sales.invoiceId = ?
        ''', [invoiceId]);
    }

    //getActive user
    Future<List<Map<String , dynamic>>> getActiveUser() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT users.*
        FROM users
        WHERE isActive = 1 
      ''');
    }

    //reset active user
    Future<void> resetActiveUser() async{
      final db = await initDB();
      await db.update('users',
      {'isActive' : 0},
        where: 'isActive = ?',
        whereArgs: [1]
      );
    }

    //get logged in user
    Future<List<Map<String, dynamic>>> getLoggedInUser(String username) async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT users.*
        FROM users
        WHERE userName = ?
      ''', [username]);
    }

    ///Get Product By ID
    Future<List<Map<String, dynamic>>> getProductById(int productid) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT products.*
        FROM products
        WHERE products.productid = ?
      ''' , [productid]);
    }

     ///Get Payment method By ID
    Future<List<Map<String, dynamic>>> getPaymentMethodById(int id) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT paymentMethods.*
        FROM paymentMethods
        WHERE paymentMethods.payMethodId = ?
      ''' , [id]);
    }

    ///Get User By ID
    Future<List<Map<String, dynamic>>> getUserById(int userid) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT users.*
        FROM users
        WHERE users.userId = ?
      ''' , [userid]);
    }

    ///Get Product By ID
    Future<List<Map<String, dynamic>>> getBankDetailsById(int bankID) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT banks.*
        FROM banks
        WHERE banks.bankId = ?
      ''' , [bankID]);
    }

    Future<void> insertBulkProducts(List<Map<String, dynamic>> products) async {
      final db = await initDB();

      // Using a transaction for better performance and atomicity
      await db.transaction((txn) async {
        for (var product in products) {
          await txn.insert(
            'products',
            product,
            conflictAlgorithm: ConflictAlgorithm.ignore, // Or replace
          );
        }
      });
    }

    //Get Default Currency
    Future<List<Map<String,dynamic>>> getDefaultPayMethod(int defaultTag) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT paymentMethods.*
        FROM paymentMethods
        WHERE paymentMethods.payMethodId = ?
      ''' , [defaultTag]);
    }

    //get selected currency
    Future<List<Map<String, dynamic>>> getSelectedCurrency(String method) async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT currency , rate
        FROM paymentMethods
        WHERE currency = ?
      ''', [method]);
    }

    //get currency and rate
    Future<List<Map<String, dynamic>>> getCurrencyAndRate(String method) async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT currency, rate
        FROM paymentMethods
        WHERE description = ?
      ''', [method]);
    }

    // Get default currency
    Future<String?> getDefaultCurrency() async {
      final db = await initDB(); // Ensure your `initDB` initializes the database
      final result = await db.rawQuery('''
        SELECT currency 
        FROM paymentMethods
        WHERE defaultMethod = 1
        LIMIT 1
      ''');

      if (result.isNotEmpty) {
        return result[0]['currency'] as String; // Return the currency
      }
      return null; // Return null if no default method is set
  }

    Future<double?> getDefaultRate() async {
      final db = await initDB(); // Ensure your `initDB` initializes the database
      final result = await db.rawQuery('''
        SELECT rate 
        FROM paymentMethods
        WHERE defaultMethod = 1
        LIMIT 1
      ''');

      if (result.isNotEmpty) {
        return result[0]['rate'] as double; // Return the rate
      }
      return null; // Return null if no default method is set
    }

    ///Get Open day Table
    Future<List<Map<String, dynamic>>> getOpenDay() async {
      final db = await initDB(); // Initialize the database
        return await db.rawQuery('''
          SELECT openDay.*
          FROM openDay
        ''');
    }

    Future<int> getlatestFiscalDay() async {
      final db = await initDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT FiscalDayNo FROM OpenDay ORDER BY ID DESC LIMIT 1");
      if(result.isNotEmpty){
        return result.first["FiscalDayNo"] as int;
      }
      return 1;
    }

    Future<int> getLatestReceiptGlobalNo() async {
      final db = await initDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT receiptGlobalNo FROM submittedReceipts ORDER BY receiptGlobalNo DESC LIMIT 1"
      );

      if (result.isNotEmpty) {
        return result.first["receiptGlobalNo"] as int;
      }
        return 0; // Default value if no records exist
    }

    Future<int> getNextReceiptCounter(int fiscalDayNo) async {
      final db = await initDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        '''
          SELECT MAX(receiptCounter) as lastCounter
          FROM submittedReceipts 
          WHERE FiscalDayNo = ?
        ''',
        [fiscalDayNo],
      );

      // Retrieve the counter from the result
      int nextCounter = (result.isNotEmpty && result.first['lastCounter'] != null) 
        ? result.first['lastCounter'] + 1 
        : 1;
      // Default value if no records exist
      return nextCounter;
    }

    //free
    Future<String> getLatestReceiptHash() async {
      final db = await initDB();
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT receiptHash FROM submittedReceipts ORDER BY receiptGlobalNo DESC LIMIT 1"
      );

      if (result.isNotEmpty) {
        return result.first["receiptHash"] ?? "";
      }
      return ""; // Return empty string if no record is found
    }
    //Get Submitted Receipts table
    Future <List<Map<String, dynamic>>> getSubmittedReceipts() async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT submittedReceipts.*
        FROM submittedReceipts
      ''');
    }

    //Get receipts by date
    Future<List<Map<String, dynamic>>> getReceiptsByDate() async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT 
          DATE(receiptDate) as sale_day,
          SUM(SalesAmountwithTax) as total_sales
          FROM submittedReceipts
          GROUP BY sale_day
          ORDER BY sale_day ASC;
      ''');
    }

    ///Get All Users From DB
    Future<List<Map<String, dynamic>>> getAllUsers() async {
      final db = await initDB(); // Initialize the database
        return await db.rawQuery('''
          SELECT users.*
          FROM users
        ''');
    }

    ///Get company details
    Future<List<Map<String, dynamic>>> getCompanyDetails() async {
      final db = await initDB(); // Initialize the database
        return await db.rawQuery('''
          SELECT companyDetails.*
          FROM companyDetails
        ''');
    }

    ///Get taxpayer details
    Future<List<Map<String, dynamic>>> getTaxPayerDetails() async {
      final db = await initDB(); // Initialize the database
        return await db.rawQuery('''
          SELECT taxPayerDetails.*
          FROM taxPayerDetails
        ''');
    }


    //////Update Product Stock Quantity
    Future<void> updateProductStockQty(int productid , int newStockQty) async{
      final db = await initDB();
      await db.update(
        'products',
        {'stockQty': newStockQty},
        where: 'productid = ?',
        whereArgs: [productid]
      );
    }

    ////UPdate stock purchase quantity
    Future<void> updateStockPurchaseQty(int purchaseId , int newStockQty) async{
      final db = await initDB();
      await db.update(
        'stockPurchases',
        {'quantity': newStockQty},
        where: 'purchaseId = ?',
        whereArgs: [purchaseId]
      );
    }

    //Get Stock Purchase by id
    Future<List<Map<String , dynamic>>> getStockPurchaseById(int purchaseId) async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT stockPurchases.*
        FROM stockPurchases
        WHERE purchaseId = ?
      ''' , [purchaseId]);
    }

    //update product
    Future<void> updateProduct(int productid, String name, String barcode , String hscode , String costPrice,
      String sellingPrice, String tax) async{
      final db = await initDB();
      await db.update(
        'products',
        {
          'productName': name,
          'barcode': barcode,
          'hsCode': hscode,
          'costPrice': costPrice,
          'sellingPrice': sellingPrice,
          'tax': tax
        },
        where: 'productid = ?',
        whereArgs: [productid]
      );
    }

    //update payment Method
    Future<void> updatePaymentMethod(int payMEthodId, String description ,double rate , String fiscGroup , String currency) async{
      final db = await initDB();
      await db.update(
        'paymentMethods',
        {
          'description': description,
          'rate': rate,
          'fiscalGroup': fiscGroup,
          'currency': currency,
        },
        where: 'payMethodId = ?',
        whereArgs: [payMEthodId]
      );
    }

    //update user
    Future<void> updateUser(int userID, String realName , String username ,String password , int isadmin,
      int iscashier) async{
      final db = await initDB();
      await db.update(
        'users',
        {
          'realName': realName,
          'userName': username,
          'userPassword': password,
          'isAdmin': isadmin,
          'isCashier': iscashier,
        },
        where: 'userId = ?',
        whereArgs: [userID]
      );
    }

    

    //update banking details
    Future<void> updateBankimgDetails(int bankID, String bank, String bankBranch , String bankAcntName , String bankAcntNo,
      String currency) async{
      final db = await initDB();
      await db.update(
        'banks',
        {
          'bank': bank,
          'bankBranch': bankBranch,
          'bankAcntName': bankAcntName,
          'bankAcntNo': bankAcntNo,
          'currency': currency
        },
        where: 'bankId = ?',
        whereArgs: [bankID]
      );
    }

    //update banking details
    Future<void> updateTaxpayerDetails(int id, String tinNumber, String name , String vatNumber , int deviceID,
      String activationKey , String modelName, String serialNo , String versionName) async{
      final db = await initDB();
      await db.update(
        'taxPayerDetails',
        {
          'taxPayerName': name,
          'taxPayerTin': tinNumber,
          'taxPayerVatNumber': vatNumber,
          'deviceID': deviceID,
          'activationKey': activationKey,
          'deviceModelName': modelName,
          'serialNo': serialNo,
          'deviceModelVersion': versionName
        },
        where: 'taxPayerId = ?',
        whereArgs: [id]
      );
    }


    //update company details
    Future<void> updateCompanyDetails(int id, String company, String logo, String address ,
      String tel , String branchName, String tel2 , String email, String tinNumber  , String vatNumber , String vendorNo, String website,
      String baseCurrency , String backup , String baseTax) async{
      final db = await initDB();
      await db.update(
        'companyDetails',
        {
          'company': company,
          'logo': logo,
          'address': address,
          'tel': tel,
          'branchName': branchName,
          'tel2': tel2,
          'email': email,
          'tinNumber': tinNumber,
          'vatNumber': vatNumber ,
          'vendorNumber': vendorNo,
          'website': website ,
          'baseCurreny': baseCurrency ,
          'backUpLocation':backup ,
          'baseTaxPercentage': baseTax 
        },
        where: 'companyID = ?',
        whereArgs: [id]
      );
    }

    //Set Default Currency
    Future<void> setDefaultCurrency(int methodId, int defaultTag) async {
      final db = await initDB();

      await db.transaction((txn) async {
        await txn.update(
          'paymentMethods',
          {'defaultMethod': 0},
          where: 'defaultMethod = ?',
          whereArgs: [1],
        );

        await txn.update(
          'paymentMethods',
          {'defaultMethod': defaultTag},
          where: 'payMethodId = ?',
          whereArgs: [methodId],
        );
      });
    }


    ///// Get all Products
    Future<List<Map<String, dynamic>>> getAllProducts() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT products.*
        FROM products
      ''');
    }

    //// Get Stock Purchases
    Future<List<Map<String ,dynamic>>> getAllStockPurchases() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT stockPurchases.*
        FROM stockPurchases
      ''');
    }

    //// Get Payment Methods
    Future<List<Map<String ,dynamic>>> getPaymentMethods() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT paymentMethods.*
        FROM paymentMethods
      ''');
    }

    //get banking details
    Future<List<Map<String ,dynamic>>> getBankingDetails() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT banks.*
        FROM banks
      ''');
    }

    //Get all customers

    Future<List<Map<String, dynamic>>> getAllCustomers() async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT customer.*
        FROM customer
      ''');
    }

    Future<List<Map<String, dynamic>>> getAllFiscalCustomers() async {
      final db = await initDB();
      return await db.rawQuery('''
        SELECT customer.*
        FROM customer
        WHERE isFiscal = 1
      ''');
    }


  Future<Map<String, int>> getPreviousReceiptData() async {
    final db = await initDB();
    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT receiptCounter, FiscalDayNo, receiptGlobalNo FROM SubmittedReceipts ORDER BY receiptGlobalNo DESC LIMIT 1");
    return result.isNotEmpty
        ? {
            "receiptCounter": result.first["receiptCounter"],
            "FiscalDayNo": result.first["FiscalDayNo"],
            "receiptGlobalNo": result.first["receiptGlobalNo"]
          }
        : {"receiptCounter": 0, "FiscalDayNo": 0, "receiptGlobalNo": 0};
  }


  Future<int> getPreviousFiscalDayNo() async {
    final db = await initDB();
    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT FiscalDayNo FROM OpenDay ORDER BY ID DESC LIMIT 1");
    return result.isNotEmpty ? result.first["FiscalDayNo"] : 0;
  }


  Future<void> insertOpenDay(
      int fiscalDayNo, String status, String fiscalDayOpened) async {
    final db = await initDB();
    await db.insert(
      'OpenDay',
      {
        'FiscalDayNo': fiscalDayNo,
        'StatusOfFirstReceipt': status,
        'FiscalDayOpened': fiscalDayOpened,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> updateDatabase(Map<String, int> taxIDs) async {
  try {
    final db = await initDB();

    // Get latest record ID
    List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT ID FROM OpenDay ORDER BY id DESC LIMIT 1");

    if (result.isNotEmpty) {
      int id = result.first["ID"];

      // Update the OpenDay table
      await db.update(
        'OpenDay',
        {
          'TaxExempt': taxIDs['Exempt'] ?? 0,
          'TaxZero': taxIDs['Zero'] ?? 0,
          'Tax15': taxIDs['VAT15'] ?? 0,
          'TaxWT': taxIDs['WT'] ?? 0,
        },
        where: 'ID = ?',
        whereArgs: [id],
      );

      print("Applicable Tax IDs Set in DB !!");
    } else {
      print("No records found in OpenDay table");
    }
  } catch (e) {
    print("Database update error: $e");
  }
}

  Future<List<Map<String,dynamic>>> getReceiptsPending() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT submittedReceipts.*
        FROM submittedReceipts
        WHERE submittedReceipts.StatustoFDMS = 'NOTSubmitted'
      ''');
  }


    Future<List<Map<String,dynamic>>> getReceiptsSubmitted() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT submittedReceipts.*
        FROM submittedReceipts
        WHERE submittedReceipts.StatustoFDMS = 'Submitted'
      ''');
    }


  Future<List<Map<String,dynamic>>> getAllReceipts() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT submittedReceipts.*
        FROM submittedReceipts
      ''');
  }


  //get unsubmitted receipts
  Future<List<Map<String,dynamic>>> getReceiptsNotSubmitted() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT submittedReceipts.*
        FROM submittedReceipts
        WHERE submittedReceipts.StatustoFDMS = 'NOTSubmitted'
      ''');
  }

  Future<List<Map<String,dynamic>>> getReceiptsSubmittedToday(int dayNo) async{
      final db = await initDB();
      return await db.rawQuery('''
          SELECT submittedReceipts.*
          FROM submittedReceipts 
          WHERE FiscalDayNo = ?
      ''', [dayNo]);
  }

  Future<List<Map<String , dynamic>>> getReceiptSubmittedById(int invoiceNum) async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT submittedReceipts.*
      FROM submittedReceipts
      WHERE InvoiceNo = ?
    ''' , [invoiceNum]);
  }

  //get day opened date
  Future<List<Map<String , dynamic>>> getDayOpenedDate(int fiscDay) async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT openDay.*
      FROM openDay
      WHERE FiscalDayNo = ?
    ''',[fiscDay]);
  }

  //get creditnote numbers

  // Future<String> getNextCreditNoteNumber() async{
  //   final db = await initDB();
  //   final result = await db.rawQuery('SELECT MAX(creditNoteNumber) as maxCr FROM credit_notes');
  //   final maxCr = result.first['maxCr'] as String?;
  //   int nextNumber = 1;

  //   if (maxCr != null) {
  //     // Extract the numeric part by removing the 'cr' prefix
  //     final numberPart = int.tryParse(maxCr.replaceFirst('cr', ''));
  //     if (numberPart != null) {
  //       nextNumber = numberPart + 1;
  //     }
  //   }

  //   // Format the new credit note number
  //   return 'cr$nextNumber';
  // }

  Future<String> getNextCreditNoteNumber() async {
  final db = await initDB();

  // Correct query: extract the numeric part after 'cr' and get the max as an INTEGER
  final result = await db.rawQuery(
    '''
    SELECT MAX(CAST(SUBSTR(creditNoteNumber, 3) AS INTEGER)) AS maxCr
    FROM credit_notes
    '''
  );

  final maxCr = result.first['maxCr'] as int?;
  final nextNumber = (maxCr ?? 0) + 1;

  return 'cr$nextNumber';
}


  //get call cancelled Receipts
  Future<List<Map<String,dynamic>>> getAllCancelledInvoices() async{
      final db = await initDB();
      return await db.rawQuery('''
        SELECT credit_notes.*
        FROM credit_notes
      ''');
  }


  Future<List<Map<String, dynamic>>> getAnomalyTable() async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT receiptAnomallies.*
      FROM receiptAnomallies
    ''');
  }


  Future<List<Map<String, dynamic>>> getFlaggedReceipts() async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT receiptAnomallies.*
      FROM receiptAnomallies
      WHERE isAnomaly = 'true'
    ''');
  }


  Future<List<Map<String, dynamic>>> getCloseDayReceipts(int fiscalDayOpened) async{
    final db = await initDB();
    return await db.query(
      'submittedReceipts',
      columns: ['receiptType','receiptJsonbody'],
      where: 'FiscalDayNo = ?',
      whereArgs: [fiscalDayOpened],
    );
  }


  Future<List<Map<String , dynamic>>> getReceiptsADetection() async {
    final db = await initDB();
    return await db.query(
      'submittedReceipts',
      columns: ['receiptGlobalNo' , 'receiptJsonbody']
    );
  }


  Future<List<Map<String, dynamic>>> getAllFiscalInvoice(String? currency) async{
    final db = await initDB();
    return await db.rawQuery(
      '''
        SELECT submittedReceipts.*
        FROM submittedReceipts
        WHERE receiptType = 'FISCALINVOICE' AND receiptCurrency = ?
      ''' , [currency]
    );
  }

  Future<List<Map<String, dynamic>>> getAllUserSales(String? user) async{
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = await initDB();
    return await db.rawQuery(
      '''
        SELECT invoices.*
        FROM invoices
        WHERE doneBY = ? AND date LIKE ? AND cancelled = 0
      ''' , [user , '$today%']
    );
  }

  Future<List<Map<String, dynamic>>> getAllUserSalesData(String? user) async{
    final db = await initDB();
    return await db.rawQuery(
      '''
        SELECT invoices.*
        FROM invoices
        WHERE doneBY = ? AND cancelled = 0
      ''' , [user]
    );
  }


  Future<List<Map<String , dynamic>>> getTotalTaxAmount(String? currency) async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT SUM(taxAmount) as totalTaxAmount
      FROM submittedReceipts WHERE receiptCurrency = ?
    ''' , [currency] );
  }


  Future<List<Map<String, dynamic>>> getTopProductsByQuantity() async {
    final database = await initDB();
    return await database.rawQuery('''
      SELECT 
        products.productId,
        products.productName,
        SUM(sales.quantity) as totalQuantity,
        SUM(sales.quantity * sales.sellingPrice) as totalSales
      FROM 
        sales
      INNER JOIN 
        products ON sales.productId = products.productId
      WHERE 
        sales.tax > 0.0
      GROUP BY 
        sales.productId
      ORDER BY 
        totalQuantity DESC
      LIMIT 2
    ''');
  }


  Future<List<Map<String , dynamic>>> getTopSellingProducts() async{
    final database = await initDB();
    return await database.rawQuery('''
        SELECT
          products.productId,
          products.productName,
          SUM(sales.quantity) as totalQuantity,
          SUM(sales.quantity * sales.sellingPrice) as totalSales
        FROM
          sales
        INNER JOIN
          products ON sales.productId = products.productId
        GROUP BY
          sales.productId
        ORDER BY
          totalQuantity DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopCustomers() async {
    final database = await initDB();
    return await database.rawQuery('''
      SELECT
        customer.tradeName AS customerName,
        COUNT(DISTINCT sales.invoiceId) AS totalInvoices,
        SUM(sales.quantity * sales.sellingPrice) AS totalSpent
      FROM
        sales
      INNER JOIN
        customer ON sales.customerID = customer.customerID
      INNER JOIN
        invoices ON sales.invoiceId = invoices.invoiceId
      WHERE
        invoices.cancelled = 0
      GROUP BY
        sales.customerID
      ORDER BY
        totalSpent DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopSellingCashiers() async {
    final database = await initDB();
    return await database.rawQuery('''
      SELECT
        sales.doneBY,
        COUNT(DISTINCT sales.invoiceId) AS totalInvoices,
        SUM(sales.quantity * sales.sellingPrice) AS totalSales
      FROM
        sales
      INNER JOIN
        invoices ON sales.invoiceId = invoices.invoiceId
      WHERE
        invoices.cancelled = 0
      GROUP BY
        sales.doneBY
      ORDER BY
        totalSales DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getzwg()async{
    final db  = await initDB();
    return await db.rawQuery('''
      SELECT * FROM sales WHERE currency = 'ZWG'
    ''');
  }


  Future<List<Map<String, dynamic>>> getZWGTotalSales()async{
    final database = await initDB();
    return await database.rawQuery('''
        SELECT
          currency,
          SUM(sales.quantity * sales.sellingPrice) as totalSales
        FROM
          sales
        WHERE
          currency = ?
    ''', ['ZWG']);
  }

  Future<List<Map<String, dynamic>>> getUSDTotalSales()async{
    final database = await initDB();
    return await database.rawQuery('''
        SELECT
          currency,
          SUM(sales.quantity * sales.sellingPrice) as totalSales
        FROM
          sales
        WHERE
          currency = ?
    ''' , ['USD']);
  }

    Future<Map<String, dynamic>> getCurrentMonthTaxDetails() async {
    final Database database = await initDB();
    final DateTime now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonth = now.month;
    final String monthName = DateFormat('MMMM').format(now);
    
    // Format for SQL substring comparison
    final String yearMonthPattern = '${currentYear}-${currentMonth < 10 ? '0$currentMonth' : currentMonth}';
    
    // First and last day formatting for display purposes
    final DateTime firstDay = DateTime(currentYear, currentMonth, 1);
    final DateTime lastDay = DateTime(currentYear, currentMonth + 1, 0);
    final String startDateFormatted = DateFormat('yyyy-MM-dd').format(firstDay);
    final String endDateFormatted = DateFormat('yyyy-MM-dd').format(lastDay);
    
    // Query using substring to extract year-month part from ISO timestamp
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT 
        SUM(taxAmount) as totalTaxAmount,
        COUNT(*) as receiptCount,
        AVG(taxAmount) as averageTaxAmount,
        SUM(SalesAmountwithTax) as totalSalesWithTax,
        SUM(TotalExempt) as totalExempt,
        SUM(TotalWT) as totalWithholdingTax
      FROM submittedReceipts
      WHERE substr(receiptDate, 1, 7) = ? AND receiptCurrency = 'ZWG'
    ''', [yearMonthPattern]);
    
    final Map<String, dynamic> taxDetails = {
      'totalTaxAmount': result.first['totalTaxAmount'] as double? ?? 0.0,
      'receiptCount': result.first['receiptCount'] as int? ?? 0,
      'averageTaxAmount': result.first['averageTaxAmount'] as double? ?? 0.0,
      'totalSalesWithTax': result.first['totalSalesWithTax'] as double? ?? 0.0,
      'totalExempt': result.first['totalExempt'] as double? ?? 0.0,
      'totalWithholdingTax': result.first['totalWithholdingTax'] as double? ?? 0.0,
      'month': monthName,
      'year': currentYear.toString(),
      'startDate': startDateFormatted,
      'endDate': endDateFormatted,
    };
    
    return taxDetails;
  }

 Future<Map<String, dynamic>> getCurrentMonthTaxDetailsUSD() async {
    final Database database = await initDB();
    final DateTime now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonth = now.month;
    final String monthName = DateFormat('MMMM').format(now);
    
    // Format for SQL substring comparison
    final String yearMonthPattern = '${currentYear}-${currentMonth < 10 ? '0$currentMonth' : currentMonth}';
    
    // First and last day formatting for display purposes
    final DateTime firstDay = DateTime(currentYear, currentMonth, 1);
    final DateTime lastDay = DateTime(currentYear, currentMonth + 1, 0);
    final String startDateFormatted = DateFormat('yyyy-MM-dd').format(firstDay);
    final String endDateFormatted = DateFormat('yyyy-MM-dd').format(lastDay);
    
    // Query using substring to extract year-month part from ISO timestamp
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT 
        SUM(taxAmount) as totalTaxAmount,
        COUNT(*) as receiptCount,
        AVG(taxAmount) as averageTaxAmount,
        SUM(SalesAmountwithTax) as totalSalesWithTax,
        SUM(TotalExempt) as totalExempt,
        SUM(TotalWT) as totalWithholdingTax
      FROM submittedReceipts
      WHERE substr(receiptDate, 1, 7) = ? AND receiptCurrency = 'USD'
    ''', [yearMonthPattern]);
    
    final Map<String, dynamic> taxDetails = {
      'totalTaxAmount': result.first['totalTaxAmount'] as double? ?? 0.0,
      'receiptCount': result.first['receiptCount'] as int? ?? 0,
      'averageTaxAmount': result.first['averageTaxAmount'] as double? ?? 0.0,
      'totalSalesWithTax': result.first['totalSalesWithTax'] as double? ?? 0.0,
      'totalExempt': result.first['totalExempt'] as double? ?? 0.0,
      'totalWithholdingTax': result.first['totalWithholdingTax'] as double? ?? 0.0,
      'month': monthName,
      'year': currentYear.toString(),
      'startDate': startDateFormatted,
      'endDate': endDateFormatted,
    };
    
    return taxDetails;
  } 

  //get all currencies
  Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    final db = await initDB();
    return await db.rawQuery('''
      SELECT paymentMethods.*
      FROM paymentMethods
    ''');
  }

  //get zwg 
  Future<List<Map<String, dynamic>>> getzwgcurrency() async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT paymentMethods.*
      FROM paymentMethods
      WHERE currency = 'ZWG'
    ''');
  }

  Future<double> getTotalSalesWithinDateRange({
    required String currency,
    required String startDate,
    required String endDate,
  }) async {
  final db = await initDB();

  final result = await db.rawQuery('''
      SELECT 
        IFNULL(SUM(invoices.totalAmount), 0) AS totalSales
      FROM 
        invoices
      WHERE 
        invoices.currency = ? AND cancelled = 0
        AND invoices.date BETWEEN ? AND ?
    ''', [currency, startDate, endDate]);

    return result.isNotEmpty ? (result[0]['totalSales'] as double) : 0.0;
  }

  Future<double> getTotalTaxWithinDateRange({
    required String currency,
    required String startDate,
    required String endDate,
  }) async {
  final db = await initDB();

  final result = await db.rawQuery('''
      SELECT 
        IFNULL(SUM(invoices.totalTax), 0) AS totalTax
      FROM 
        invoices
      WHERE 
        invoices.currency = ? AND cancelled = 0
        AND invoices.date BETWEEN ? AND ?
    ''', [currency, startDate, endDate]);

    return result.isNotEmpty ? (result[0]['totalTax'] as num).toDouble() : 0.0;
  }


  //get daily sales summmary

  Future<Map<String, dynamic>> getSalesSummary() async {

    final db = await initDB();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final usd = await db.rawQuery('''
      SELECT SUM(totalAmount) as total FROM invoices 
      WHERE currency = 'USD' AND cancelled = 0 AND date LIKE ?
    ''', ['$today%']);

    final zwg = await db.rawQuery('''
      SELECT SUM(totalAmount) as total FROM invoices 
      WHERE currency = 'ZWG' AND cancelled = 0 AND date LIKE ?
    ''', ['$today%']);

    final zar = await db.rawQuery('''
      SELECT SUM(totalAmount) as total FROM invoices 
      WHERE currency = 'ZAR' AND cancelled = 0 AND date LIKE ?
    ''', ['$today%']);

    return {
      'usdTotal': usd.first['total'] ?? 0.0,
      'zwgTotal': zwg.first['total'] ?? 0.0,
      'zarTotal': zar.first['total'] ?? 0.0,
    };
  }


  Future<List<Map<String, dynamic>>> getZReportTotals(int dayNo , String currency) async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT
        SUM(receiptTotal) sumZWGReceiptTotal,
        SUM(taxAmount) as sumZWGTaxAmount,
        SUM(Total15VAT) as sumZWG15VAT,
        SUM(TotalNonVAT) as sumZWGNonVAT,
        SUM(TotalExempt) as sumZWGExempt
      FROM submittedReceipts
      WHERE FiscalDayNo = ?  AND receiptCurrency = ?
      ''' , [dayNo , currency]);
  }

  Future<List<Map<String , dynamic>>> getZreportDocumentTotals(int dayNo , String receiptType,  String currency) async {
    final db = await initDB();
    return await db.rawQuery('''
      SELECT SUM(receiptTotal) as total
      FROM submittedReceipts
      WHERE FiscalDayNo = ?  AND receiptCurrency = ? AND receiptType = ?
    ''' , [dayNo , currency , receiptType]);
  }

  Future<List<Map<String, dynamic>>> getDocumentsCounter(int dayNo , String currency , String receiptType) async{
    final db = await initDB();
    return await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM submittedReceipts
      WHERE FiscalDayNo = ?  AND receiptCurrency = ? AND receiptType = ?
    ''', [dayNo , currency , receiptType]);
  }

  Future<List<Map<String, dynamic>>> getSalesByCustomer(int customerId) async {
    final db = await initDB();

    return await db.rawQuery('''
      SELECT sales.* 
      FROM sales
      LEFT JOIN products ON sales.productId = products.productid
      WHERE sales.customerID = ?
    ''', [customerId]);
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await initDB(); // your open db instance
    final results = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (results.isNotEmpty) {
      return results.first; // returns first product found
    }
    return null; // no product found
  }

}