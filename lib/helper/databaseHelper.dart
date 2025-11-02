import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const String _databaseName = 'db.db';
  static const int _databaseVersion = 1;

  // Instância única da classe
  static final DatabaseHelper instance = DatabaseHelper._();

  // Database privado
  Database? _database;

  // Construtor privado
  DatabaseHelper._();

  // Getter assíncrono para o banco de dados
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Inicializa e abre o banco de dados
  Future<Database> _initDatabase() async {
    try {
      // Obtém o diretório de documentos do aplicativo (seguro para escrita)
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = join(directory.path, _databaseName);

      print('Database path: $dbPath');

      return await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onConfigure: (db) async {
          // Ativar chaves estrangeiras
          await db.execute('PRAGMA foreign_keys = ON;');
        },
      );
    } catch (e) {
      print('Erro ao abrir o banco de dados: $e');
      rethrow;
    }
  }

  // Método chamado na criação do banco de dados
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT, 
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT,
        isGoogleUser INTEGER NOT NULL,
        avatarUrl TEXT,
        number TEXT,
        lastname TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        street TEXT NOT NULL,
        number TEXT NOT NULL,
        bairro TEXT NOT NULL,
        complement TEXT,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        telefone TEXT NOT NULL,
        zipCode TEXT NOT NULL,
        horario TEXT, 
        observacao TEXT,
        isPrimary INTEGER DEFAULT 0,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL, -- vendedor
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL, -- comprador
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        userId INTEGER NOT NULL
      )
    ''');
  }

  // Função para fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
