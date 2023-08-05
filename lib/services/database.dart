import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const columnId = 'id';

const tableLists = 'lists';
const columnTitle = 'title';

const tableTasks = 'tasks';
const columnListId = 'list_id';
const columnTask = 'task';
const columnChecked = 'checked';

class TodoTask {
  int? id;
  int listId;
  String task;
  bool checked;

  TodoTask(
      {this.id,
      required this.task,
      required this.checked,
      required this.listId});

  TodoTask.fromMap(Map<String, dynamic> res)
      : id = res[columnId],
        listId = res[columnListId],
        task = res[columnTask],
        checked = res[columnChecked] == 1;

  Map<String, Object?> toMap() {
    return {
      columnId: id,
      columnListId: listId,
      columnTask: task,
      columnChecked: checked ? 1 : 0
    };
  }
}

class TodoList {
  int? id;
  String title;

  TodoList({this.id, required this.title});

  TodoList.fromMap(Map<String, dynamic> res)
      : id = res[columnId],
        title = res[columnTitle];

  Map<String, Object?> toMap() {
    return {columnId: id, columnTitle: title};
  }
}

class DatabaseHelper {
  static const _databaseName = "packy.db";
  static const _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    batch.execute(
      """
        CREATE TABLE $tableLists (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
          $columnTitle TEXT NOT NULL
        );
      """,
    );
    batch.execute(
      """
        CREATE TABLE $tableTasks (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnListId INTEGER NOT NULL, 
          $columnTask TEXT NOT NULL,
          $columnChecked INTEGER NOT NULL
        );
      """,
    );
    await batch.commit();
  }

  Future<List<TodoList>> retrieveLists() async {
    Database db = await instance.database;

    final List<Map<String, Object?>> queryResult = await db.query(tableLists);
    var lists = queryResult.map((e) => TodoList.fromMap(e)).toList();
    return lists;
  }

  Future<void> resetList(int listId) async {
    Database db = await instance.database;

    await db.execute(
        'UPDATE $tableTasks SET $columnChecked = 0 WHERE $columnListId = ?',
        [listId]);
  }

  Future<int> insertList(TodoList list) async {
    Database db = await instance.database;

    int result = await db.insert(tableLists, list.toMap());
    return result;
  }

  Future<int> removeList(int listId) async {
    Database db = await instance.database;
    db.delete(tableTasks, where: '$columnListId = ?', whereArgs: [listId]);
    return await db
        .delete(tableLists, where: '$columnId = ?', whereArgs: [listId]);
  }

  Future<List<TodoTask>> retrieveTasks(int listId) async {
    Database db = await instance.database;

    final List<Map<String, Object?>> queryResult = await db
        .query(tableTasks, where: '$columnListId = ?', whereArgs: [listId]);
    var tasks = queryResult.map((e) => TodoTask.fromMap(e)).toList();
    return tasks;
  }

  Future<int> insertTask(TodoTask task) async {
    Database db = await instance.database;

    int id = await db.insert(tableTasks, task.toMap());
    return id;
  }

  Future<void> toggleTask(int taskId, bool newValue) async {
    Database db = await instance.database;

    await db.execute(
        'UPDATE $tableTasks SET $columnChecked = $newValue WHERE $columnId = ?',
        [taskId]);
  }

  Future<int> removeTask(int taskId) async {
    Database db = await instance.database;

    int result = await db
        .delete(tableTasks, where: '$columnId = ?', whereArgs: [taskId]);
    return result;
  }

  Future<int> clearDb() async {
    Database db = await instance.database;

    int result = await db.delete(tableLists);
    return result;
  }
}
