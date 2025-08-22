import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adb_tools/providers/app_provider.dart';
import 'package:adb_tools/utils/setup.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'pages/main_page.dart';

const int port = 6666;

Future<void> main(List<String> args) async {
  bool isServer = false;
  ServerSocket? server;
  WidgetRef? widgetRef;

  try {
    // 尝试建立Socket服务器（第一个实例）
    server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    isServer = true;

    print("Socket 服务已启动，等待文件路径...");
    server.listen((client) {
      print("收到连接: ${client.remoteAddress.address}:${client.remotePort}");
      client.transform(StreamTransformer.fromHandlers(
        handleData: (Uint8List data, EventSink<String> sink) {
          sink.add(utf8.decode(data));
        },
      )).listen((data) {
        print("收到文件路径: $data");
        // TODO: 在这里处理接收到的文件路径，比如将文件保存到filesProvider中
        if (widgetRef == null) return;
        var xfile = XFile(data);
        widgetRef?.read(filesProvider.notifier).state = [...widgetRef?.read(filesProvider.notifier).state ?? [], xfile];
      });
    });
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
        print("已将文件路径传给主实例: $filePath");
      } catch (e) {
        print("发送文件路径失败: $e");
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

  runApp(ProviderScope(child: Consumer(
    builder: (context, ref, child) {
      widgetRef = ref;
      return const MainApp();
    },
  )));
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

    // Initialize the setup
    SteupUtils.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
      ),
      home: const MainPage(),
    );
  }
}
