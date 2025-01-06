import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pulsepay/JsonModels/users.dart';

class DatabaseHelper {
  final databaseName = "pulse.db";

  String users = 
    "create table users(userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE , userPassword TEXT)";
  
  String products =
    "create table products(productid INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT UNIQUE , barcode TEXT , costPrice REAL , sellingPrice REAL , sellqty REAL , tax TEXT)";

  String invoices =
    "create table invoices (invoiceId INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,totalAmount REAL,totalTax REAL)";

  String sales = 
    "CREATE TABLE sales (saleId INTEGER PRIMARY KEY AUTOINCREMENT,invoiceId INTEGER,productId INTEGER,quantity INTEGER,sellingPrice REAL,tax REAL,FOREIGN KEY(invoiceId) REFERENCES invoices(invoiceId),FOREIGN KEY(productId) REFERENCES products(productid))";

  // vat zero ex

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath , databaseName);
    //await deleteDatabase(path);

    return openDatabase(path , version: 1 , onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(products);
      await db.execute(invoices);
      await db.execute(sales);
    }  , onUpgrade: (db ,oldVersion , newVersion) async {
      if(oldVersion > 2){
        await db.execute(products);
      }
    });
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

  //signup
  Future<int> signup(Users user)async{
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  //add products
  Future<int> addProduct(Products product) async{
    final Database db = await initDB();
    return db.insert('products', product.toMap());
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

  //invoice numbers
  Future<int> getNextInvoiceId() async {
    final db = await initDB();
    final result = await db.rawQuery('SELECT MAX(invoiceId) as lastId FROM invoices');
    int lastId = result.first['lastId'] as int? ?? 0; // Start at 0 if no invoices
    return lastId + 1;
  }

  //save sale
  Future<void> saveSale(List<Map<String, dynamic>> cartItems, double totalAmount, double totalTax , double indiTax) async {
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
    });

    // Insert into sales table
    for (var item in cartItems) {
      await txn.insert('sales', {
        'invoiceId': invoiceId,
        'productId': item['productid'],
        'quantity': item['sellqty'],
        'sellingPrice': item['sellingPrice'],
        'tax': indiTax, // Calculate per-item tax if necessary
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


}