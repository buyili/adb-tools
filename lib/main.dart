import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adb_tools/providers/app_provider.dart';
import 'package:adb_tools/utils/dialog_utils.dart';
import 'package:adb_tools/utils/setup.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/main_page.dart';

const int port = kDebugMode ? 6665 : 6666;

ServerSocket? server;

Future<void> main(List<String> args) async {
  bool isServer = false;

  try {
    // 尝试建立Socket服务器（第一个实例）
    server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    isServer = true;

    debugPrint("Socket 服务已启动，等待文件路径...");
    // 监听函数在ProvideScope组件下_MainAppState中调用
  } catch (e) {
    isServer = false;
  }

  if (!isServer) {
    // 如果不是Server，说明已有实例在运行 → 把参数传过去
    if (args.isNotEmpty) {
      final filePath = args[0];
      try {
        final socket = await Socket.connect(InternetAddress.loopbackIPv4, port);
        socket.write(filePath);
        await socket.flush();
        await socket.close();
        debugPrint("已将文件路径传给主实例: $filePath");
      } catch (e) {
        debugPrint("发送文件路径失败: $e");
      }
    }
    // 退出自己
    exit(0);
  }

  // Try to resize and reposition the window to be half the width and height
  // of its screen, centered horizontally and shifted up from center.
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();

    // 监听端口
    if (server != null) {
      server?.listen((client) {
        debugPrint(
            "收到连接: ${client.remoteAddress.address}:${client.remotePort}");
        client.transform(StreamTransformer.fromHandlers(
          handleData: (Uint8List data, EventSink<String> sink) {
            sink.add(utf8.decode(data));
          },
        )).listen((data) {
          debugPrint("收到文件路径: $data");
          // 在这里处理接收到的文件路径，比如将文件保存到filesProvider中

          var xfile = XFile(data);
          var files = ref.read(filesProvider);
          var index = files.indexWhere((file) => file.path == data);
          if (index != -1) {
            DialogUtils.showFileExsistDialog(xfile.name);
            return;
          }

          ref.read(filesProvider.notifier).state = [...files, xfile];
        });
      });
    }

    // Initialize the setup
    SteupUtils.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
      ),
      home: const MainPage(),
    );
  }
}
