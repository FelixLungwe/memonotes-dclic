import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const String _databaseName = 'memonotes.db';

  static const int _databaseVersion = 1;

  static const String _notesTable = 'notes';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();

    final String path = join(databasesPath, _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_notesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        date_creation TEXT NOT NULL,
        date_modification TEXT NOT NULL
      )
      ''');
  }

  Future<int> insertNote(Note note) async {
    final Database db = await database;

    return db.insert(_notesTable, note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _notesTable,
      orderBy: 'date_modification DESC',
    );

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    if (note.id == null) {
      throw ArgumentError('Impossible de modifier une note sans identifiant.');
    }

    final Database db = await database;

    return db.update(
      _notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final Database db = await database;

    return db.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final Database? db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
