import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/device.dart';
import '../models/scrcpy_related/scrcpy_config.dart';
import '../providers/config_provider.dart';
import '../utils/const.dart';
import '../utils/prefs_key.dart';

class Db {

  /*
  Device DB
  */

  static Future<void> saveAdbDevice(List<Device> dev) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        PKEY_SAVED_DEVICES, dev.map((e) => e.toJson()).toList());
    // prefs.remove(PKEY_SAVED_DEVICES);
  }

  static Future<List<Device>> getSavedAdbDevice() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove(PKEY_SAVED_DEVICES);
    final jsons = prefs.getStringList(PKEY_SAVED_DEVICES) ?? [];

    return jsons.map((e) => Device.fromJson(e)).toList();
  }

  /*
  Configs DB
  */

  static Future<List<ScrcpyConfig>> getSavedConfig() async {
    List<ScrcpyConfig> saved = [];
    final prefs = await SharedPreferences.getInstance();

    final res = prefs.getStringList(PKEY_SAVED_CONFIG) ?? [];

    for (var r in res) {
      saved.add(ScrcpyConfig.fromJson(r));
    }

    return saved;
  }

  static Future<void> saveMainConfig(ScrcpyConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(PKEY_MAIN_CONFIG, config.toJson());
  }

  static  Future<ScrcpyConfig> getMainConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsons = prefs.getString(PKEY_MAIN_CONFIG);

    if (jsons == null) {
      return defaultMirror;
    } else {
      return ScrcpyConfig.fromJson(jsons);
    }
  }

  static Future<void> saveLastUsedConfig(ScrcpyConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(PKEY_LASTUSED_CONFIG, config.id);
  }

  static Future<ScrcpyConfig?> getLastUsedConfig(WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allConfig = ref.read(configsProvider);

      final res = prefs.getString(PKEY_LASTUSED_CONFIG) ?? defaultMirror.id;

      final lastUsed = allConfig.firstWhere((c) => c.id == res);

      return lastUsed;
    } on StateError catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> saveConfigs(BuildContext context, List<ScrcpyConfig> conf) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedJson = [];

    for (var c in conf) {
      savedJson.add(c.toJson());
    }

    prefs.setStringList(PKEY_SAVED_CONFIG, savedJson);
  }

}
