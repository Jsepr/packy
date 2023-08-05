import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_again/components/text_input_form.dart';
import 'package:todo_again/layouts/main_layout.dart';
import 'package:todo_again/providers/tasks_provider.dart';
import 'package:todo_again/services/database.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key, required this.list});

  final TodoList list;

  @override
  State<StatefulWidget> createState() {
    return _ListScreenState();
  }
}

class _ListScreenState extends State<ListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.primary),
          Padding(
              padding: EdgeInsets.only(left: 4), child: Text(widget.list.title))
        ],
      ),
      floatingActionButton: AddTaskFAB(widget: widget),
      appBarActions: [ResetListButton(widget: widget)],
      body: Center(
        child: TaskList(list: widget.list),
      ),
    );
  }
}

class ResetListButton extends StatelessWidget {
  const ResetListButton({
    super.key,
    required this.widget,
  });

  final ListScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        return IconButton(
            onPressed: () async {
              await tasksProvider.resetList(widget.list.id!);
            },
            icon: const Icon(Icons.recycling));
      },
    );
  }
}

class AddTaskFAB extends StatelessWidget {
  const AddTaskFAB({
    super.key,
    required this.widget,
  });

  final ListScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
        builder: (consumerContext, tasksProvider, child) {
      return FloatingActionButton(
        onPressed: () => showModalBottomSheet<String>(
          context: context,
          builder: (BuildContext context) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 32,
                left: 16,
                right: 16),
            child: TextInputForm(
              header: 'Ny uppgift',
              hintText: 'Uppgift',
              errorText: 'Uppgift kan inte vara tom',
              submitButtonText: 'Lägg till',
              onSuccess: (value) {
                tasksProvider
                    .addTask(
                        widget.list,
                        TodoTask(
                            listId: widget.list.id!,
                            task: value,
                            checked: false))
                    .then(
                  (value) {
                    Navigator.pop(consumerContext);
                  },
                );
              },
            ),
          ),
        ),
        tooltip: 'Ny uppgift',
        child: Icon(Icons.add),
      );
    });
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.list});

  final TodoList list;

  @override
  State<StatefulWidget> createState() {
    return _TaskListState();
  }
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        var listTasks = tasksProvider.getListTasks(widget.list.id!);
        if (listTasks.isLoading) {
          return const CircularProgressIndicator();
        }

        return ListView(
          children: [
            ...(listTasks.tasks.isEmpty
                ? [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: const Center(child: Text("Din lista är tom")),
                    )
                  ]
                : [
                    ...listTasks.tasks.map(
                      (task) {
                        return CheckboxListTile(
                          key: Key(task.id.toString()),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: task.checked,
                          checkboxShape: const CircleBorder(),
                          onChanged: (newValue) {
                            tasksProvider.toggleTask(
                                widget.list, task.id!, !task.checked);
                          },
                          title: Text(task.task),
                        );
                      },
                    ).toList(),
                    ...(listTasks.tasks.length < 10
                        ? List.generate(
                            10 - listTasks.tasks.length, (index) => ListTile())
                        : [])
                  ]),
            const ListTile(
              key: Key("suggestions-title"),
              minVerticalPadding: 0,
              title: Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "Förslag",
                  style: TextStyle(fontSize: 24, color: Colors.black87),
                ),
              ),
              subtitle: Text("AI-genererade förslag baserade på din lista"),
            ),
            if (listTasks.isLoadingSuggestions)
              Container(
                  height: 50,
                  child: Center(child: CircularProgressIndicator())),
            ...listTasks.suggestions.map(
              (suggestion) {
                return ListTile(
                  key: Key(suggestion),
                  trailing: Icon(Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary),
                  onTap: () {
                    tasksProvider.addTask(
                        widget.list,
                        TodoTask(
                            task: suggestion,
                            checked: false,
                            listId: widget.list.id!));
                  },
                  title: Text(suggestion),
                );
              },
            ).toList()
          ],
        );
      },
    );
  }
}
