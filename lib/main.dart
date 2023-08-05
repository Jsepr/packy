import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_again/screens/home_screen.dart';

import 'providers/tasks_provider.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TodoAgainApp());
}

var myColor = MaterialColor(
  const Color.fromRGBO(39, 110, 31, 0.5).value,
  const <int, Color>{
    50: Color.fromRGBO(64, 175, 50, 0.1),
    100: Color.fromRGBO(64, 175, 50, 0.2),
    200: Color.fromRGBO(64, 175, 50, 0.3),
    300: Color.fromRGBO(64, 175, 50, 0.4),
    400: Color.fromRGBO(64, 175, 50, 0.5),
    500: Color.fromRGBO(64, 175, 50, 0.6),
    600: Color.fromRGBO(64, 175, 50, 0.7),
    700: Color.fromRGBO(64, 175, 50, 0.8),
    800: Color.fromRGBO(64, 175, 50, 0.9),
    900: Color.fromRGBO(64, 175, 50, 1),
  },
);

class TodoAgainApp extends StatelessWidget {
  const TodoAgainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TasksProvider(),
      child: MaterialApp(
          title: 'Packy',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: myColor),
            textTheme: GoogleFonts.openSansTextTheme(),
            useMaterial3: true,
          ),
          home: const HomeScreen()),
    );
  }
}
