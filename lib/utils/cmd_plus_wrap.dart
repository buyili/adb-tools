import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cmd_plus/cmd_plus.dart';
import 'package:io/ansi.dart' as ansi;

/// A wrapper around [CmdPlus] to override the output encoding.
class CmdPlusWrap extends CmdPlus {
  @override
  Future<CmdPlusResult> run(
    String cmd,
    List<String> args, {
    bool throwOnError = true,
    bool runInShell = true,
    bool includeParentEnvironment = true,
    String? workingDirectory,
    Map<String, String>? environment,
    CmdPlusMode mode = const CmdPlusMode.normal(),
  }) async {
    final result = await _overrideAnsiOutput(
      true,
      () => Process.run(
        cmd,
        args,
        workingDirectory: workingDirectory,
        runInShell: runInShell,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        stderrEncoding: utf8,
        stdoutEncoding: utf8,
      ),
    );

    final error = result.stderr.toString();
    final output = result.stdout.toString();
    final showOutput = mode.maybeMap<bool>(
      detached: (_) => false,
      orElse: () => true,
    );

    if (showOutput) {
      if (output.isNotEmpty) logger.write(output);
      if (error.isNotEmpty) logger.err(error);
    }

    if (throwOnError && result.exitCode != 0) {
      throw ProcessException(
        cmd,
        args,
        'Process exited with exit code $exitCode',
        exitCode,
      );
    }

    return CmdPlusResult(
      exitCode: exitCode,
      output: output,
      error: error,
    );
  }

  T _overrideAnsiOutput<T>(bool enableAnsiOutput, T Function() body) =>
      runZoned(
        body,
        zoneValues: <Object, Object>{
          ansi.AnsiCode: enableAnsiOutput,
          // ignore: equal_keys_in_map
          AnsiCode: enableAnsiOutput,
        },
      );
}
