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

    return await openDatabase(
      path,
      version: 2, // A versão continua 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ✅ MODIFICADO AQUI
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários (CORRIGIDA E SINCRONIZADA)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastname TEXT,                   -- 👈 ADICIONADO
        email TEXT NOT NULL UNIQUE,      -- 👈 ADICIONADO 'UNIQUE'
        password TEXT,                 -- 👈 ADICIONADO
        number TEXT,                   -- 👈 ADICIONADO
        avatarUrl TEXT,
        isGoogleUser INTEGER NOT NULL DEFAULT 0, -- 👈 GARANTIDO O 'DEFAULT 0'
        role TEXT NOT NULL DEFAULT 'student',
        classId TEXT
      )
    ''');
  }

  // A função onUpgrade ainda existe para futuras migrações
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // Como o _onCreate foi modificado, a melhor forma de atualizar
      // é desinstalando o app. Mas para migrações futuras,
      // o código de migração viria aqui.
      
      // Exemplo (não exatamente o seu caso, mas para referência):
      // await db.execute("ALTER TABLE users ADD COLUMN lastname TEXT");
      // await db.execute("ALTER TABLE users ADD COLUMN password TEXT");
      // await db.execute("ALTER TABLE users ADD COLUMN number TEXT");
      // await db.execute("ALTER TABLE users ADD COLUMN isGoogleUser INTEGER NOT NULL DEFAULT 0");
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

