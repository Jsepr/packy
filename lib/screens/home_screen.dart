import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_again/components/list_list_item.dart';
import 'package:todo_again/components/text_input_form.dart';
import 'package:todo_again/layouts/main_layout.dart';
import 'package:todo_again/services/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<TodoList> lists = [];

  @override
  void initState() {
    super.initState();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text(
          "Packy",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<String>(
          context: context,
          builder: (BuildContext context) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 32,
                left: 16,
                right: 16),
            child: TextInputForm(
              header: 'Ny lista',
              hintText: 'Skriv in ett namn för listan',
              errorText: 'Namn kan inte vara tomt',
              submitButtonText: 'Spara',
              onSuccess: (value) {
                DatabaseHelper.instance
                    .insertList(TodoList(title: value))
                    .then((value) {
                  setState(() {});
                  Navigator.pop(context);
                });
              },
            ),
          ),
        ),
        tooltip: 'Ny lista',
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder(
          future: DatabaseHelper.instance.retrieveLists(),
          builder:
              (BuildContext context, AsyncSnapshot<List<TodoList>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Text("Du har inte skapat några listor än.");
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var list = snapshot.data![index];
                  return RemovableListItem(list: list);
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
