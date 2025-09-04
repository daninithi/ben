import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class MessageDbHelper {
  static final MessageDbHelper _instance = MessageDbHelper._internal();
  factory MessageDbHelper() => _instance;
  MessageDbHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            text TEXT,
            senderId TEXT,
            receiverId TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertMessage(Message message) async {
    final database = await db;
    await database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> getMessages() async {
    final database = await db;
    final maps = await database.query('messages');
    return maps.map((map) => Message.fromMap(map)).toList();
  }
}
