import 'dart:async';

import 'package:colorfool/extensions/list/filter.dart';
import 'package:colorfool/services/crud/crud_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class ColorsService {
  Database? _db;
  DatabaseUser? _user;

  static final ColorsService _shared = ColorsService._sharedInstance();
  ColorsService._sharedInstance() {
    _colorsStreamController = StreamController<List<DatabaseColor>>.broadcast(
      onListen: () {
        _colorsStreamController.sink.add(_colors);
      },
    );
  }
  factory ColorsService() => _shared;

  List<DatabaseColor> _colors = [];
  late final StreamController<List<DatabaseColor>> _colorsStreamController;

  Stream<List<DatabaseColor>> get allColors =>
      _colorsStreamController.stream.filter((color) {
        final currentUser = _user;
        if (currentUser != null) {
          return color.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllColors();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrent = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrent) _user = user;
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrent) _user = createdUser;
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheColor() async {
    final allColors = await getAllColors();
    _colors = allColors.toList();
    _colorsStreamController.add(_colors);
  }

  Future<DatabaseColor> updateColor(
      {required DatabaseColor color, required String colorCode}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getColor(id: color.id);

    final updatesCount = await db.update(
      colorTable,
      {
        "color_code": colorCode,
        "is_synced_with_cloud": 0,
      },
      where: "id = ?",
      whereArgs: [color.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateColor();
    } else {
      final updatedColor = await getColor(id: color.id);
      _colors.removeWhere((element) => element.id == updatedColor.id);
      _colors.add(updatedColor);
      _colorsStreamController.add(_colors);
      return updatedColor;
    }
  }

  Future<Iterable<DatabaseColor>> getAllColors() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(colorTable);
    return results.map((n) => DatabaseColor.fromRow(n));
  }

  Future<DatabaseColor> getColor({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      colorTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindColor();
    } else {
      final color = DatabaseColor.fromRow(results.first);
      _colors.removeWhere((element) => element.id == id);
      _colors.add(color);
      _colorsStreamController.add(_colors);
      return color;
    }
  }

  Future<int> deleteAllColors() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(colorTable);
    _colors = [];
    _colorsStreamController.add(_colors);
    return numberOfDeletions;
  }

  Future<void> deleteColor({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      colorTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteColor();
    } else {
      _colors.removeWhere((color) => color.id == id);
      _colorsStreamController.add(_colors);
    }
  }

  Future<DatabaseColor> createColor({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const colorCode = "";
    final colorId = await db.insert(colorTable, {
      "user_id": owner.id,
      "color_code": colorCode,
      "is_synced_with_cloud": 1,
    });

    final color = DatabaseColor(
      id: colorId,
      userId: owner.id,
      colorCode: colorCode,
      isSyncedWithCloud: true,
    );

    _colors.add(color);
    _colorsStreamController.add(_colors);

    return color;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {"email": email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty here
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create the User table
      const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id"	INTEGER NOT NULL,
          "email"	TEXT UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';
      await db.execute(createUserTable);

      // Create the Color table
      const createColorTable = '''
        CREATE TABLE IF NOT EXISTS "colors" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "color_code"	TEXT NOT NULL DEFAULT "#FFFFFF",
          "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY("user_id") REFERENCES "user"("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';
      await db.execute(createColorTable);

      await _cacheColor();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, id = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseColor {
  final int id;
  final int userId;
  final String colorCode;
  final bool isSyncedWithCloud;
  const DatabaseColor({
    required this.id,
    required this.userId,
    required this.colorCode,
    required this.isSyncedWithCloud,
  });

  DatabaseColor.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map["user_id"] as int,
        colorCode = map["color_code"] as String,
        isSyncedWithCloud = map["is_synced_with_cloud"] as int == 1;

  @override
  String toString() =>
      'Color, id = $id, userId = $userId, color code = $colorCode, synced with cloud : $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseColor other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'colorfool_db';
const colorTable = 'colors';
const userTable = 'user';
const idColumn = "id";
const emailColumn = "email";
