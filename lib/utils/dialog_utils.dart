import 'package:flutter/material.dart';

class DialogUtils {
  static void showInfoDialog(BuildContext context, String title, String message) {
    showDialog(context: context, builder: (context){
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
}