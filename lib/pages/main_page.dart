import 'package:adb_tools/components/my_text_form_field.dart';
import 'package:adb_tools/data/isar_db.dart';
import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/providers/device_list_model.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:adb_tools/views/apk_drop_target.dart';
import 'package:adb_tools/views/device_list.dart';
import 'package:adb_tools/views/main_page_right_side.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

import '../main.dart';

const String defaultPort = '5555';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final Isar _isar = IsarDb.getIns();

  DeviceInfo? selectedDevice;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late DeviceListModel deviceListModel;

  // selected apk files
  final List<XFile> _apkFileList = [];

  @override
  void initState() {
    deviceListModel = ref.read(deviceListProvider);

    // execute method after current widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showConnectedDevices();
    });
    super.initState();
  }

  // show connected devices
  Future<void> showConnectedDevices() async {
    List<DeviceInfo> tempConnectedDevices = await ADBUtils.devices();
    var dbDevices = _isar.devices.where().findAllSync();
    deviceListModel.setConnectedDevices(tempConnectedDevices);
    deviceListModel.setHistoryDevices(
        dbDevices.map((device) => DeviceInfo.fromDevice(device)).toList());

    if (selectedDevice != null) {
      var idx = deviceListModel.allDevices.indexWhere(
          (ele) => ele.serialNumber == selectedDevice?.serialNumber);
      if (idx != -1) {
        setState(() {
          selectedDevice = deviceListModel.allDevices[idx];
        });
      }
    }

    // Update isar data
    _isar.writeTxnSync(() {
      for (var onlineDevice in tempConnectedDevices) {
        var idx = dbDevices
            .indexWhere((ele) => ele.serialNumber == onlineDevice.serialNumber);
        if (idx == -1) {
          var newDevice = Device()
            ..serialNumber = onlineDevice.serialNumber
            ..product = onlineDevice.product
            ..model = onlineDevice.model
            ..device = onlineDevice.device
            ..transportId = onlineDevice.transportId;
          _isar.devices.putSync(newDevice);
          deviceListModel.addHistoryDevice(newDevice);
          continue;
        }
        final dbDevice = _isar.devices.getSync(onlineDevice.id);
        if (dbDevice == null) continue;
        dbDevice
          ..serialNumber = onlineDevice.serialNumber
          ..product = onlineDevice.product
          ..model = onlineDevice.model
          ..device = onlineDevice.device
          ..transportId = onlineDevice.transportId;
        _isar.devices.putSync(dbDevice);
      }
    });
  }

  // execute enter command
  Future<void> onExecuteEnterCommand(text) async {
    String command = text;
    if (command.isEmpty) {
      return;
    }
    command = command.trim();
    command = command.replaceAll('adb', '');
    command = command.replaceAll('\n', '');
    var args = command.split(" ");
    args = args.where((arg) => arg.isNotEmpty).toList();

    if (selectedDevice != null) {
      args = ['-s', selectedDevice!.serialNumber, ...args];
    }

    await ADBUtils.runCmd('adb', args);
  }

  // connect to device and save ip address and port to isar
  void onConnectInputIPAddress(String ip, String port) async {
    // connect to device
    bool connected = await ADBUtils.connect('$ip:$port');
    showConnectedDevices();
    if (!connected) {
      debugPrint("connection failed");
      return;
    }

    onSaveDeviceIPAddressToDB(ip, port);
  }

  // save ip address and port to isar
  void onSaveDeviceIPAddressToDB(String ip, String port,
      {bool showExistsSnackBar = true}) async {
    // save ip address and port to isar
    var serialNumber = '$ip:$port';
    int count = _isar.devices
        .where()
        .filter()
        .serialNumberEqualTo(serialNumber)
        .countSync();
    if (count == 0) {
      var newDevice = Device()..serialNumber = serialNumber;
      _isar.writeTxnSync(() {
        _isar.devices.putSync(
          newDevice,
        );
      });
      deviceListModel.addHistoryDevice(newDevice);
    } else {
      if (showExistsSnackBar) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('$serialNumber already exists.')),
        );
      }
    }
  }

  void onSelect(DeviceInfo device) {
    if (selectedDevice == null) {
      setState(() {
        selectedDevice = device;
      });
      return;
    }
    setState(() {
      selectedDevice =
          selectedDevice?.serialNumber == device.serialNumber ? null : device;
    });
  }

  // open port for use adb over Wi-Fi
  void onOpenTcpipPort(DeviceInfo device) async {
    await ADBUtils.openTcpipPort(device.serialNumber);
  }

  // connect to device by host and port
  void onConnect(DeviceInfo device) async {
    await ADBUtils.connect(device.serialNumber);
    await showConnectedDevices();
  }

  // get device ip and connect
  void onGetIpAndConnect(DeviceInfo device) async {
    // check tcpip opened
    var tcpipOpened = await ADBUtils.checkTcpipOpened(device.serialNumber);
    if (!tcpipOpened) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Please open tcpip port first.')),
      );
      return;
    }

    // get device ip
    var ip = await ADBUtils.getDeviceIp(device.serialNumber);
    if (ip.isEmpty) {
      // show snackbar if ip is empty
      var snackBar = SnackBar(
        content: Text('Not found device ip for ${device.serialNumber}.'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      return;
    }

    await ADBUtils.connect(ip);
    onSaveDeviceIPAddressToDB(ip, "5555", showExistsSnackBar: false);
    await showConnectedDevices();
  }

  // disconnect device on TCP/IP
  void onDisconnect(DeviceInfo device) async {
    var success = await ADBUtils.disconnect(device.serialNumber);
    if (success && device == selectedDevice) {
      setState(() {
        selectedDevice = null;
      });
    }
    await showConnectedDevices();
  }

  // delete device from isar
  void onDelete(Device device) {
    showDeleteDialog(
      context,
      'Delete Device',
      'Are you sure you want to delete ${device.serialNumber}?',
      () {
        _isar.writeTxnSync(() {
          _isar.devices.deleteSync(device.id);
        });
        deviceListModel.removeHistoryDeviceById(device.id);
      },
    );
  }

  // start shizuku
  void onStartShizuku() {
    ADBUtils.startShizuku(selectedDevice!.serialNumber);
  }

  // install apk to device
  void onInstall() {
    ADBUtils.install(selectedDevice, _apkFileList);
  }

  // push file to device
  void onPush() {
    ADBUtils.push(selectedDevice, _apkFileList);
  }

  // clear all apk files
  void onClearAll() {
    setState(() {
      _apkFileList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // text input
                    TopForm(
                      onSubmit: onConnectInputIPAddress,
                      onSave: onSaveDeviceIPAddressToDB,
                    ),

                    // device list
                    DeviceList(
                      selectedDevice: selectedDevice,
                      onSelect: onSelect,
                      onOpenTcpipPort: onOpenTcpipPort,
                      onConnect: onConnect,
                      onDisconnect: onDisconnect,
                      onDelete: onDelete,
                      onGetIpAndConnect: onGetIpAndConnect,
                    ),

                    ApkDragTarget(
                      list: _apkFileList,
                      targetDevice: selectedDevice,
                      onStartShizuku: onStartShizuku,
                      onInstall: onInstall,
                      onPush: onPush,
                      onClearAll: onClearAll,
                    ),
                  ],
                ),
              ),

              // right side
              RightSideWidget(
                onShowDevices: showConnectedDevices,
                onExecute: onExecuteEnterCommand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// top form
class TopForm extends StatefulWidget {
  final Function onSubmit;
  final Function onSave;

  const TopForm({super.key, required this.onSubmit, required this.onSave});

  @override
  State<TopForm> createState() => _TopFormState();
}

class _TopFormState extends State<TopForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // in text field
            SizedBox(
              width: 140,
              child: MyTextFormField(
                controller: _ipController,
                hintText: '192.168.2.207',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ip address.';
                  }
                  return null;
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                ':',
                style: TextStyle(fontSize: 24.0),
              ),
            ),

            // port text field
            SizedBox(
              width: 80,
              child: MyTextFormField(
                controller: _portController,
                hintText: defaultPort,
              ),
            ),

            const SizedBox(width: 10.0),

            // connect button
            FilledButton.tonal(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(
                    _ipController.text,
                    _portController.text.isNotEmpty
                        ? _portController.text
                        : defaultPort,
                  );
                }
              },
              child: const Text('Connect'),
            ),

            const SizedBox(width: 10.0),

            // save button
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(
                    _ipController.text,
                    _portController.text.isNotEmpty
                        ? _portController.text
                        : defaultPort,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> showDeleteDialog(
  BuildContext context,
  String title,
  String message,
  void Function()? onPressed,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onPressed!();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
