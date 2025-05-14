import 'dart:convert';

import 'package:adb_tools/models/scrcpy_related/scrcpy_config.dart';
import 'package:adb_tools/models/cmd_task.dart';
import 'package:adb_tools/providers/app_provider.dart';
import 'package:process_run/process_run.dart';

import '../providers/output_text_model.dart';

class ScrcpyUtils {
  static const String cmd = "scrcpy";

  static Future<void> run(String script) async {
    // get OutputTextModel instance.
    OutputTextNotifier notifier = OutputTextModelFactory.getIns();

    int taskIndex = notifier.addTask(script);

    var controller = ShellLinesController();
    var shell = Shell(
        workingDirectory: workDir,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
        stdout: controller.sink,
        verbose: false);
    controller.stream.listen((event) {
      // Handle output
      notifier.addTaskOutputLine(taskIndex, event);

      // ...
      // If needed kill the shell
      // shell.kill();
    });
    try {
      await shell.run(script);

      notifier.updateTaskStatus(taskIndex, CmdTaskStatus.success);
    } on ShellException catch (_) {
      // We might get a shell exception
      notifier.updateTaskStatus(taskIndex, CmdTaskStatus.failure);
    }
  }

  static Future<void> start(String serial, ScrcpyConfig config) async {
    final turnScreenOff = config.deviceOptions.turnOffDisplay;
    final showTouches = config.deviceOptions.showTouches;
    final stayAwake = config.deviceOptions.stayAwake;
    await run(
        "$cmd -s $serial ${turnScreenOff ? '-S' : ''} ${showTouches ? '--show-touches' : ''} ${stayAwake ? '--stay-awake' : ''}");
  }
}
