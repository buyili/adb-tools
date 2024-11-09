import 'package:adb_tools/models/cmd_task.dart';
import 'package:flutter/material.dart';

class OutputTextModel extends ChangeNotifier {
  List<CmdTask> tasks = [];

  int addTask(String cmd) {
    CmdTask task = CmdTask();
    task.cmd = cmd;
    tasks.add(task);
    notifyListeners();
    return tasks.length - 1;
  }

  void updateTask(int index, String output) {
    tasks[index].output = output;
    notifyListeners();
  }

  void clear() {
    tasks.clear();
    notifyListeners();
  }
}
