import 'package:adb_tools/data/isar_db.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/main_page.dart';

Future<void> main() async {
  await IsarDb.initInstance();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (context) => OutputTextModel(),
        child: const MainPage(),
      ),
    );
  }
}
