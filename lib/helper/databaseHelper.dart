import 'dart:async';
import 'package:path/path.dart';


import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exportasystem.db');

    final db = await openDatabase(
      path,
     
      version: 4, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }
  
  Future<void> _onCreate(Database db, int version) async {
   
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT UNIQUE, 
        name TEXT NOT NULL,
        lastname TEXT,                   
        email TEXT NOT NULL UNIQUE,      
        password TEXT,                 
        number TEXT,                   
        avatarUrl TEXT,
        isGoogleUser INTEGER NOT NULL DEFAULT 0, 
        role TEXT NOT NULL DEFAULT 'student',
        classId TEXT
      )
    ''');

    await _ensureBookingsTable(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 3) {
      
      await _ensureBookingsTable(db);
    }
    
   
    if (oldV < 4) {
      await db.execute("ALTER TABLE users ADD COLUMN firebaseUid TEXT");
   
      await db.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email);");
      await db.execute("CREATE INDEX IF NOT EXISTS idx_users_firebaseUid ON users(firebaseUid);");
    }
  }

  Future<void> _ensureBookingsTable(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      remoteId TEXT UNIQUE,
      numeroBooking TEXT NOT NULL,
      armador TEXT NOT NULL,
      navio TEXT,
      portoEmbarque TEXT NOT NULL,
      portoDesembarque TEXT NOT NULL,
      previsaoEmbarque INTEGER NOT NULL,
      previsaoDesembarque INTEGER NOT NULL,
      quantidadeContainers INTEGER NOT NULL DEFAULT 0,
      freetimeOrigem TEXT,
      freetimeDestino TEXT,
      deadlineDraft INTEGER,
      deadlineVgm INTEGER,
      deadlineCarga INTEGER,
      createdAt INTEGER NOT NULL,
      updatedAt INTEGER NOT NULL,
      dirty INTEGER NOT NULL DEFAULT 0,
      deleted INTEGER NOT NULL DEFAULT 0
    );
  ''');
  
  await db.execute(
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_bookings_remoteId ON bookings(remoteId);'
  );
}

Future<void> close() async {
  final db = await database;
  await db.close();
}
}