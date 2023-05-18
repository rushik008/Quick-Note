import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_note/pages/home.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  await Hive.openBox('box_name');

  // creating directory in local storage(phone storage)
  // var directory = await getApplicationDocumentsDirectory();

  // Initializes Hive with a valid directory path
  // Hive.init(directory.path);

  // register adapter
  // Hive.registerAdapter(NotesModelAdapter());

  // open box
  // notes-> name of the box, NotesModel-> notes model
  // await Hive.openBox<NotesModel>('notes');
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Set the primary swatch
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
