import 'package:adb_tools/providers/cmd_task.dart';
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

  void addTaskOutput(int index, String output) {
    tasks[index].output += output;
    notifyListeners();
  }

  void addTaskOutputLine(int index, String output) {
    addTaskOutput(index, '$output\n');
  }

  void updateTaskStatus(int index, String status) {
    tasks[index].status = status;
    notifyListeners();
  }

  void clear() {
    tasks.clear();
    notifyListeners();
  }
}

class OutputTextModelFactory {
  static OutputTextModel? model;

  static OutputTextModel getIns(){
    if(model != null) {
      return model!;
    }
    model = OutputTextModel();
    return model!;
  }
}