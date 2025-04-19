import 'dart:convert';

import 'package:adb_tools/providers/cmd_task.dart';
import 'package:process_run/process_run.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/output_text_model.dart';
import 'cmd_plus_wrap.dart';

class ScrcpyUtils {
  static final cmdPlus = CmdPlusWrap();
  static const workingDirectory = bool.fromEnvironment('dart.vm.product')
      ? './data/flutter_assets/assets/scrcpy-win64'
      : './assets/scrcpy-win64';
  static const String cmd = "scrcpy";

  static Future<void> run(String script) async {
    // get OutputTextModel instance.
    OutputTextModel model = OutputTextModelFactory.getIns();

    int taskIndex = model.addTask(script);

    var controller = ShellLinesController();
    var shell = Shell(
        workingDirectory: workingDirectory,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
        stdout: controller.sink,
        verbose: false);
    controller.stream.listen((event) {
      // Handle output
      model.addTaskOutputLine(taskIndex, event);

      // ...
      // If needed kill the shell
      // shell.kill();
    });
    try {
      await shell.run(script);

      model.updateTaskStatus(taskIndex, CmdTaskStatus.success);
    } on ShellException catch (_) {
      // We might get a shell exception
      model.updateTaskStatus(taskIndex, CmdTaskStatus.failure);
    }
  }

  static Future<void> start(String serial) async {
    final prefs = await SharedPreferences.getInstance();
    final turnScreenOff = prefs.getBool('turnScreenOff') ?? false;
    await run("$cmd -s $serial ${turnScreenOff ? '-S' : ''}");
  }
}
