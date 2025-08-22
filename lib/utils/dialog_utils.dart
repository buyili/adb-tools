import 'package:flutter/material.dart';

class DialogUtils {

  static BuildContext? _context;

  static void init(BuildContext context) {
    _context = context;
  }

  static void showInfoDialog(String title, String message) {
    if (_context == null || !_context!.mounted) {
      debugPrint("DialogUtils: _context is null");
      return;
    }

    showDialog(context: _context!, builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  static void showFileExsistDialog(String fileName) {
    showInfoDialog("File Exists", "File [$fileName] already exists.");
  }
}