import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_again/providers/tasks_provider.dart';
import 'package:todo_again/screens/list_screen.dart';
import 'package:todo_again/services/database.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.list});

  final TodoList list;

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(list.title.toUpperCase()[0])),
            title: Text(list.title),
            contentPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 4, top: 4),
            onTap: () {
              tasksProvider.getTasksAndSuggestions(list);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListScreen(list: list),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
