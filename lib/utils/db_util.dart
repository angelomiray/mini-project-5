import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbUtil {
  //operações com o bd SQLite
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'places2.db'),
      onCreate: (db, version) {
        //executa o ddl para cirar o banco
        return db.execute(
            'CREATE TABLE places (id TEXT PRIMARY KEY, title TEXT, image TEXT, latitude REAL, longitude REAL, address TEXT, phoneNumber TEXT)');
      },
      version: 5,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DbUtil.database();

    List<Map<String, dynamic>> allData = await db.query(table);
    if (allData.length >= 5) {
      // remove o item mais antigo (o primeiro na lista)
      await db.delete(table, where: 'id = ?', whereArgs: [allData.first['id']]);
    }

    await db.insert(
      table,
      data,
      conflictAlgorithm: sql
          .ConflictAlgorithm.replace, //se inserir algo conlfitante (substitui)
    );
  }

  static Future<void> updateItem(
      String table, String id, Map<String, Object> newItem) async {
    final db = await DbUtil.database();
    await db.update(
      table,
      newItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteItem(String table, String id) async {
    final db = await DbUtil.database();
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteAllItems(String table) async {
    final db = await DbUtil.database();
    await db.delete(table);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbUtil.database();
    return db.query(table);
  }
}
