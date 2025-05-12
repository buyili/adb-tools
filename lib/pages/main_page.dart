import 'dart:async';

import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/pages/man_page/left_side.dart';
import 'package:adb_tools/pages/man_page/right_side.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  @override
  void initState() {
    _init();

    // execute method after current widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDeviceList(ref, printOutput: false);

      Timer.periodic(const Duration(minutes: 10), (timer) {
        refreshDeviceList(ref, printOutput: false);
      });
    });
    super.initState();
  }

  Future<void> _init() async {
    var dbDevices = await Db.getSavedAdbDevice();
    ref.read(deviceListNotifierProvider).setHistoryDevices(dbDevices);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(12.0),
          child: const Row(
            children: [
              Flexible(
                flex: 8,
                child: LeftSide(),
              ),

              // right side
              Flexible(
                flex: 5,
                child: RightSideWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
