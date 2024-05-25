import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_application_1/DataBase/Tarea.dart';
import 'package:flutter_application_1/DataBase/Usuario.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
  String path = join(await getDatabasesPath(), 'Taskmanager.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE usuarios (
          idUsuario INTEGER PRIMARY KEY,
          nombreUsuario TEXT,
          apellidoUsuario TEXT,
          email TEXT,
          contrasena TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE categorias (
          idCategoria INTEGER PRIMARY KEY ,
          nombreCategoria TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE tareas (
          idTarea INTEGER PRIMARY KEY,
          nombreTarea TEXT,
          descripcion TEXT,
          fecha_limite DATE,
          importancia INTEGER,
          id_categoria INTEGER,
          id_usuario INTEGER,
          FOREIGN KEY (id_categoria) REFERENCES categorias (idCategoria),
          FOREIGN KEY (id_usuario) REFERENCES usuarios (idUsuario)
        )
      ''');

      await insertDefaultCategories();
    },
  );
}

 Future<void> insertDefaultCategories() async {
  final db = await database;

  List<Map<String, dynamic>> existingCategories = await db.query('categorias');

  if (!existingCategories.any((category) => category['idCategoria'] == 1)) {
    await db.insert(
      'categorias',
      {
        'idCategoria': 1,
        'nombreCategoria': 'Trabajo',
      },
    );
  }

  if (!existingCategories.any((category) => category['idCategoria'] == 2)) {
    await db.insert(
      'categorias',
      {
        'idCategoria': 2,
        'nombreCategoria': 'Personal',
      },
    );
  }

  if (!existingCategories.any((category) => category['idCategoria'] == 3)) {
    await db.insert(
      'categorias',
      {
        'idCategoria': 3,
        'nombreCategoria': 'Estudios',
      },
    );
  }

  if (!existingCategories.any((category) => category['idCategoria'] == 4)) {
    await db.insert(
      'categorias',
      {
        'idCategoria': 4,
        'nombreCategoria': 'Otro',
      },
    );
  }
}

  Future<int?> authenticated(String email, String password) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('usuarios', where: 'email =?', whereArgs: [email]);
  if (maps.isEmpty) {
    return null; 
  }
  final usuario = Usuario.fromMap(maps.first);

  final String encryptedPassword = sha256.convert(utf8.encode(password)).toString();
  if (usuario.contrasena == encryptedPassword) {
    return usuario.idUsuario; 
  } else {
    return null;
  }
}

  Future<bool> register(String nombre, String apellido, String email, String password) async {
    final db = await database;
    final String encryptedPassword = sha256.convert(utf8.encode(password)).toString();
    final id = await db.insert('usuarios', {
      'nombreUsuario': nombre,
      'apellidoUsuario': apellido,
      'email': email,
      'contrasena': encryptedPassword,
    });
    return id > 0;
  }

  Future<int> getIdUsuario() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    if (maps.isEmpty) {
      return 0;
    }
    final usuario = Usuario.fromMap(maps.first);
    return usuario.idUsuario;
  }

  Future<void> insertTask(String nombreTarea, String descripcion, DateTime fechaLimite, int importancia, String categoria, int idUsuario) async {
  final db = await database;

  final List<Map<String, dynamic>> maps = await db.query(
    'categorias',
    where: 'nombreCategoria = ?',
    whereArgs: [categoria],
  );
  int idCategoria = maps.isNotEmpty ? maps.first['idCategoria'] : 0;

  if (idCategoria == 0) {
    throw Exception('Categoría no encontrada');
  }

  await db.insert(
    'tareas',
    {
      'nombreTarea': nombreTarea,
      'descripcion': descripcion,
      'fecha_limite': fechaLimite.toIso8601String(),
      'importancia': importancia,
      'id_categoria': idCategoria,
      'id_usuario': idUsuario,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<void> updateTask(Tarea tarea) async {
    final db = await database;

    await db.update(
      'tareas',
      tarea.toMap(),
      where: "idTarea = ?",
      whereArgs: [tarea.idTarea],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;

    await db.delete(
      'tareas',
      where: "idTarea = ?",
      whereArgs: [id],
    );
  }

  Future<Tarea?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tareas',
      where: 'idTarea = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tarea.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Tarea>> getTasks(int idUsuario) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'tareas',
    where: 'id_usuario = ?',
    whereArgs: [idUsuario],
  );
  if (maps.isEmpty) {
    return [];
  }
  return List.generate(maps.length, (i) {
    return Tarea.fromMap(maps[i]);
  });
}

  Future<List<String>> getCategories() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('categorias');
  
  
  if (maps.isEmpty) {
    return [];
  }

  return List.generate(maps.length, (i) {
    return maps[i]['nombreCategoria'] ?? ''; 
  });
}


  Future<List<Map<String, dynamic>>> query(String s) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(s);
    return maps.isEmpty ? [] : maps;
  }

    Future<List<Tarea>> getTasksByCategory(String categoria, int idUsuario) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*
      FROM tareas t
      INNER JOIN categorias c ON t.id_categoria = c.idCategoria
      WHERE c.nombreCategoria = ? AND t.id_usuario = ?
    ''', [categoria, idUsuario]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Tarea.fromMap(maps[i]);
    });
  }

  
}
