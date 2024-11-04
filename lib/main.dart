import 'package:adb_tools/data/isar_db.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:window_size/window_size.dart' as window_size;

import 'pages/main_page.dart';

Future<void> main() async {
  // Try to resize and reposition the window to be half the width and height
  // of its screen, centered horizontally and shifted up from center.
  WidgetsFlutterBinding.ensureInitialized();
  window_size.getWindowInfo().then((window) {
    final screen = window.screen;
    if (screen != null) {
      final screenFrame = screen.visibleFrame;
      final width = math.max((screenFrame.width / 2).roundToDouble(), 960.0);
      final height = math.max((screenFrame.height / 2).roundToDouble(), 560.0);
      final left =
          screenFrame.left + ((screenFrame.width - width) / 2).roundToDouble();
      final top =
          screenFrame.top + ((screenFrame.height - height) / 2).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      window_size.setWindowFrame(frame);
      window_size.setWindowMinSize(Size(0.8 * width, 0.8 * height));
      window_size.setWindowMaxSize(Size(1.5 * width, 1.5 * height));
      window_size.setWindowTitle('ADB Tools');
    }
  });

  // Initialize the Isar database
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
