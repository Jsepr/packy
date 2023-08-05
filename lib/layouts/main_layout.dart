import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  const MainLayout(
      {super.key,
      required this.title,
      required this.body,
      this.appBarActions,
      this.floatingActionButton});

  final Widget title;
  final Widget body;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
        titleSpacing: 0,
        title: title,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary, fontSize: 20),
        centerTitle: false,
        actions: appBarActions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
