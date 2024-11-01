import 'package:flutter/material.dart';

class OutputTextModel extends ChangeNotifier {
  String output = '';

  void updateOutput(String newOutput) {
    output += newOutput;
    notifyListeners();
  }

  void clearOutput() {
    output = '';
    notifyListeners();
  }
}
