import 'dart:io';

import 'package:adb_tools/providers/app_provider.dart';
import 'package:adb_tools/utils/const.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SteupUtils {
  static final String _appPath = Platform.resolvedExecutable;

  static String get appDir =>
      _appPath.substring(0, _appPath.lastIndexOf(Platform.pathSeparator));

  static String get macAppDir {
    final macos =
        appDir.substring(0, _appPath.lastIndexOf(Platform.pathSeparator));

    final contents =
        macos.substring(0, macos.lastIndexOf(Platform.pathSeparator));
    return contents;
  }

  static String get getLinuxExec =>
      "$appDir/data/flutter_assets/assets/exec/linux";

  static String get getWindowsExec =>
      "$appDir\\data\\flutter_assets\\assets\\exec\\win";

  static String get getIntelMacExec =>
      "$macAppDir/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/exec/mac-aarch64";

  static String get getAppleMacExec =>
      "$macAppDir/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/exec/mac-x86_64";

  static init() async {
    final execPath = await _getExecPath();
    // ref.read(execDirProvider.notifier).update((state) => execPath);
    workDir = execPath;
    logger.i('exec path: $execPath');
  }

  static Future<String> _getExecPath() async {
    logger.i('OS: ${Platform.operatingSystem}');

    if (Platform.isLinux) {
      final info = await DeviceInfoPlugin().linuxInfo;
      logger.i(info.prettyName);

      return getLinuxExec;
    } else if (Platform.isMacOS) {
      final info = await DeviceInfoPlugin().macOsInfo;
      final arch = info.arch;

      logger.i('Arch: $arch');

      if (arch == 'x86_64') {
        return getIntelMacExec;
      }
      return getAppleMacExec;
    } else if (Platform.isWindows) {
      return getWindowsExec;
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
