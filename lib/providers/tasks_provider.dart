import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_again/services/database.dart';

class ListTasks {
  List<TodoTask> tasks = [];
  List<String> suggestions = [];
  bool isLoading = true;
  bool isLoadingSuggestions = true;
}

class TasksProvider with ChangeNotifier {
  bool _mounted = true;

  var allListTasks = <int, ListTasks>{};

  @override
  void dispose() {
    super.dispose();
    _mounted = false;
  }

  @override
  void notifyListeners() {
    if (!_mounted) return;
    super.notifyListeners();
  }

  ListTasks getListTasks(int listId) => allListTasks[listId] ??= ListTasks();

  Future<void> getTasks(TodoList list) async {
    var listTasks = getListTasks(list.id!);
    listTasks.tasks = await DatabaseHelper.instance.retrieveTasks(list.id!);

    if (!_mounted) return;
    listTasks.isLoading = false;
    notifyListeners();
  }

  Future<void> getTasksAndSuggestions(TodoList list) async {
    await getTasks(list);
    var listTasks = getListTasks(list.id!);
    if (!_mounted ||
        (!listTasks.isLoadingSuggestions && listTasks.suggestions.isNotEmpty)) {
      return;
    }
    await getSuggestions(list);
  }

  Future<void> resetList(int listId) async {
    var listTasks = getListTasks(listId);

    for (var t in listTasks.tasks) {
      t.checked = false;
    }
    notifyListeners();
    await DatabaseHelper.instance.resetList(listId);
  }

  Future<void> getSuggestions(TodoList list) async {
    var listTasks = getListTasks(list.id!);

    try {
      var response = await http.post(
          Uri.parse(
              'https://europe-west3-reusable-checklists-394708.cloudfunctions.net/checklist-suggestions'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "listTitle": list.title,
            "tasks": listTasks.tasks.map((t) => t.task).toList()
          }));
      if (!_mounted) return;

      final List<String> suggestionList =
          (jsonDecode(response.body) as List).map((e) => e.toString()).toList();
      listTasks.suggestions = suggestionList;
    } catch (e) {
      print("Couldn't parse OpenAPI response: $e");
    } finally {
      listTasks.isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  Future<void> addTask(TodoList list, TodoTask task) async {
    var listTasks = getListTasks(list.id!);

    var taskId = await DatabaseHelper.instance.insertTask(task);
    if (!_mounted) return;

    task.id = taskId;
    listTasks.tasks.add(task);

    listTasks.suggestions =
        listTasks.suggestions.where((e) => e != task.task).toList();

    notifyListeners();
  }

  Future<void> toggleTask(TodoList list, int taskId, bool checked) async {
    var listTasks = getListTasks(list.id!);

    DatabaseHelper.instance.toggleTask(taskId, checked);

    for (var t in listTasks.tasks) {
      if (t.id == taskId) {
        t.checked = !t.checked;
      }
    }

    notifyListeners();
  }
}
