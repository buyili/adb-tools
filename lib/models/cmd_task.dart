import 'package:flutter/material.dart';

class CmdTask {
  String cmd = "";
  String output = "";
  String status = CmdTaskStatus.running;
}

class CmdTaskStatus {
  static const String success = "success";
  static const String failure = "failure";
  static const String running = "running";

  static Color getColor(String status) {
    switch (status) {
      case success:
        return Colors.green;
      case failure:
        return Colors.red;
      case running:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }

}
