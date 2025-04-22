import 'dart:async';

import 'package:adb_tools/components/my_text_form_field.dart';
import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/pages/man_page/apk_drop_target.dart';
import 'package:adb_tools/pages/man_page/device_list.dart';
import 'package:adb_tools/pages/man_page/main_page_right_side.dart';
import 'package:adb_tools/providers/device_list_model.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String defaultPort = '5555';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late DeviceListModel deviceListModel;

  @override
  void initState() {
    deviceListModel = ref.read(deviceListProvider);

    // execute method after current widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showConnectedDevices();

      Timer.periodic(const Duration(seconds: 10), (timer) {
        showConnectedDevices(printOutput: false);
      });
    });
    super.initState();
  }

  // show connected devices
  Future<void> showConnectedDevices({
    bool printOutput = true,
  }) async {
    List<DeviceInfo> tempConnectedDevices =
        await ADBUtils.devices(printOutput: printOutput);
    var dbDevices = await Db.getSavedAdbDevice();
    deviceListModel.setConnectedDevices(tempConnectedDevices);
    deviceListModel.setHistoryDevices(
        dbDevices.map((device) => DeviceInfo.fromDevice(device)).toList());

    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice != null) {
      var idx = deviceListModel.connectedDevices
          .indexWhere((ele) => ele.serialNumber == selectedDevice.serialNumber);
      if (idx != -1) {
        setState(() {
          ref.read(selectedDeviceProvider.notifier).state =
              deviceListModel.connectedDevices[idx];
        });
      }
    }

    for (var onlineDevice in tempConnectedDevices) {
      var idx = dbDevices
          .indexWhere((ele) => ele.serialNumber == onlineDevice.serialNumber);

      if (idx != -1) {
        dbDevices[idx]
          ..serialNumber = onlineDevice.serialNumber
          ..product = onlineDevice.product
          ..model = onlineDevice.model
          ..device = onlineDevice.device
          ..transportId = onlineDevice.transportId;
      } else if (onlineDevice.wifi) {
        var newDevice = Device()
          ..serialNumber = onlineDevice.serialNumber
          ..product = onlineDevice.product
          ..model = onlineDevice.model
          ..device = onlineDevice.device
          ..transportId = onlineDevice.transportId;
        dbDevices.add(newDevice);
      }
    }
    Db.saveAdbDevice(dbDevices);
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

    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice != null) {
      args = ['-s', selectedDevice.serialNumber, ...args];
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

    onSaveDeviceIPAddressToDB(ip, port, showExistsSnackBar: false);
  }

  // save ip address and port to isar
  void onSaveDeviceIPAddressToDB(String ip, String port,
      {bool showExistsSnackBar = true}) async {
    // save ip address and port to isar
    var serialNumber = '$ip:$port';
    bool exists = deviceListModel.historyDevices
        .any((device) => device.serialNumber == serialNumber);
    if (exists) {
      if (showExistsSnackBar) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('$serialNumber already exists.')),
        );
      }
    } else {
      var newDevice = Device()..serialNumber = serialNumber;
      deviceListModel.addHistoryDevice(newDevice);
      Db.saveAdbDevice(deviceListModel.historyDevices);
    }
  }

  void onSelect(DeviceInfo device) {
    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice == null) {
      ref.read(selectedDeviceProvider.notifier).state = device;
      return;
    }
    ref.read(selectedDeviceProvider.notifier).state =
        selectedDevice.serialNumber == device.serialNumber ? null : device;
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
        content: Text('Not found device ip for [${device.serialNumber}].'),
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
    if (success && device == ref.watch(selectedDeviceProvider)) {
      setState(() {
        ref.read(selectedDeviceProvider.notifier).state = null;
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
        deviceListModel.removeHistoryDeviceById(device.serialNumber);
        Db.saveAdbDevice(deviceListModel.historyDevices);
      },
    );
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
                      onSelect: onSelect,
                      onConnect: onConnect,
                      onDisconnect: onDisconnect,
                      onDelete: onDelete,
                      onGetIpAndConnect: onGetIpAndConnect,
                    ),

                    const ApkDragTarget(),
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

  const TopForm({
    super.key,
    required this.onSubmit,
    required this.onSave,
  });

  @override
  State<TopForm> createState() => _TopFormState();
}

class _TopFormState extends State<TopForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  List<String> getIpAndPort() {
    var ip = '';
    var port = '';
    if (_ipController.text.contains(':')) {
      ip = _ipController.text.split(':')[0];
      port = _ipController.text.split(':')[1];
    } else {
      ip = _ipController.text;
      port =
          _portController.text.isNotEmpty ? _portController.text : defaultPort;
    }
    return [ip, port];
  }

  void _toggleConnect() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(getIpAndPort()[0], getIpAndPort()[1]);
    }
  }

  void _toggleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(getIpAndPort()[0], getIpAndPort()[1]);
    }
  }

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
              width: 180,
              child: MyTextFormField(
                controller: _ipController,
                hintText: 'ip or ip:port',
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
                _toggleConnect();
              },
              child: const Text('Connect'),
            ),

            const SizedBox(width: 10.0),

            // save button
            FilledButton(
              onPressed: () {
                _toggleSave();
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
