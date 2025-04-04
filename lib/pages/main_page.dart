import 'package:adb_tools/components/my_text_form_field.dart';
import 'package:adb_tools/data/isar_db.dart';
import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:adb_tools/views/apk_drop_target.dart';
import 'package:adb_tools/views/device_list.dart';
import 'package:adb_tools/views/main_page_right_side.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

const String defaultPort = '5555';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Isar _isar = IsarDb.getIns();
  List<DeviceInfo> devices = [];
  List<DeviceInfo> connectedDevices = [];
  DeviceInfo? selectedDevice;
  late OutputTextModel model;
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // selected apk files
  final List<XFile> _apkFileList = [];

  @override
  void initState() {
    showConnectedDevices();

    model = Provider.of<OutputTextModel>(context, listen: false);
    model.addListener(() {
      // scroll to top when offset is not 0
      if (_scrollController.offset != 0) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });

    Stream<void> deviceIpsChanged = _isar.devices.watchLazy();
    deviceIpsChanged.listen((_) {
      setState(() {
        devices = DeviceInfo.merge(
            _isar.devices.where().findAllSync(), connectedDevices);
      });
    });
    super.initState();
  }

  // show connected devices
  Future<void> showConnectedDevices() async {
    List<DeviceInfo> listOfDevices = await ADBUtils.devices();
    var dbDevices = _isar.devices.where().findAllSync();
    var newDevices = DeviceInfo.merge(dbDevices, listOfDevices);
    setState(() {
      connectedDevices = listOfDevices;
      devices = newDevices;
    });

    if (selectedDevice != null) {
      var idx = devices.indexWhere(
          (ele) => ele.serialNumber == selectedDevice?.serialNumber);
      if (idx != -1) {
        setState(() {
          selectedDevice = devices[idx];
        });
      }
    }

    // Update isar data
    await _isar.writeTxn(() async {
      for (var item in dbDevices) {
        var idx = listOfDevices
            .indexWhere((ele) => ele.serialNumber == item.serialNumber);
        if (idx == -1) {
          continue;
        }
        final dbDevice = await _isar.devices.get(item.id);
        if (dbDevice == null) continue;
        var target = listOfDevices[idx];
        await _isar.devices.put(dbDevice
          ..serialNumber = target.serialNumber
          ..product = target.product
          ..model = target.model
          ..device = target.device
          ..transportId = target.transportId);
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
  void onSubmit(String ip, String port) async {
    // connect to device
    bool connected = await ADBUtils.connect('$ip:$port');
    showConnectedDevices();
    if (!connected) {
      debugPrint("connection failed");
      return;
    }

    onSave(ip, port);
  }

  // save ip address and port to isar
  void onSave(String ip, String port) async {
    // save ip address and port to isar
    int count = _isar.devices
        .where()
        .filter()
        .ipEqualTo(ip)
        .portEqualTo(port)
        .countSync();
    var serialNumber = '$ip:$port';
    if (count == 0) {
      _isar.writeTxnSync(() {
        _isar.devices.putSync(
          Device()
            ..ip = ip
            ..port = port
            ..serialNumber = serialNumber,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$serialNumber already exists.')),
      );
    }
  }

  void onSelect(DeviceInfo device) {
    setState(() {
      selectedDevice = selectedDevice == device ? null : device;
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
    await showConnectedDevices();
  }

  // disconnect device
  void onDisconnect(DeviceInfo device) async {
    await ADBUtils.disconnect(device.serialNumber);
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
      },
    );
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
                      onSubmit: onSubmit,
                      onSave: onSave,
                    ),

                    // device list
                    DeviceList(
                      devices: devices,
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
                      onInstall: onInstall,
                      onPush: onPush,
                      onClearAll: onClearAll,
                    ),
                  ],
                ),
              ),

              // right side
              RightSideWidget(
                model: model,
                scrollController: _scrollController,
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
