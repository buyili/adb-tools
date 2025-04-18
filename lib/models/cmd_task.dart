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
  static const String canceled = "canceled";

  static Color getColor(String status) {
    switch (status) {
      case success:
        return Colors.green;
      case failure:
        return Colors.red;
      case running:
        return Colors.blue;
      case canceled:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

}
