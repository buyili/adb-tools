import 'package:adb_tools/components/my_text_form_field.dart';
import 'package:adb_tools/data/isar_db.dart';
import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:adb_tools/views/apk_drop_target.dart';
import 'package:adb_tools/views/device_list_tile.dart';
import 'package:adb_tools/views/output_view.dart';
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
        devices = DeviceInfo.merge(_isar.devices.where().findAllSync(), connectedDevices);
      });
    });
    super.initState();
  }

  // show connected devices
  Future<void> showConnectedDevices() async {
    List<DeviceInfo> listOfDevices = await ADBUtils.devices();
    setState(() {
      connectedDevices = listOfDevices;
      devices =
          DeviceInfo.merge(_isar.devices.where().findAllSync(), listOfDevices);
      if (selectedDevice != null) {
        var idx = devices.indexWhere(
            (ele) => ele.serialNumber == selectedDevice?.serialNumber);
        if (idx != -1) {
          selectedDevice = devices[idx];
        }
      }
    });
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
    if (count == 0) {
      _isar.writeTxnSync(() {
        _isar.devices.putSync(
          Device()
            ..ip = ip
            ..port = port,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$ip:$port already exists.')),
      );
    }
  }

  void onSelect(DeviceInfo device) {
    setState(() {
      selectedDevice = device;
    });
  }

  // connect to device
  void onConnect(DeviceInfo device) async {
    await ADBUtils.connect(device.serialNumber);
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
      'Are you sure you want to delete ${device.host}?',
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
  void onPush(){
    ADBUtils.push(selectedDevice, _apkFileList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 24.0),
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

                  // history list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return DeviceListTile(
                            device: devices[index],
                            isSelected: selectedDevice == devices[index],
                            onTap: () {
                              onSelect(devices[index]);
                            },
                            onConnect: () {
                              onConnect(devices[index]);
                            },
                            onDisconnect: () {
                              onDisconnect(devices[index]);
                            },
                            onDelete: () {
                              onDelete(devices[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  ApkDragTarget(
                    list: _apkFileList,
                    targetDevice: selectedDevice,
                    onInstall: onInstall,
                    onPush: onPush,
                  ),
                ],
              ),
            ),

            // right side
            RightSideWidget(
              model: model,
              scrollController: _scrollController,
              onShowDevices: showConnectedDevices,
            ),
          ],
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
        padding: const EdgeInsets.only(left: 12.0, top: 12),
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

/// right side widget
class RightSideWidget extends StatelessWidget {
  const RightSideWidget({
    super.key,
    required this.model,
    required ScrollController scrollController,
    required this.onShowDevices,
  }) : _scrollController = scrollController;

  final OutputTextModel model;
  final ScrollController _scrollController;
  final Function onShowDevices;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  onShowDevices();
                },
                child: const Text('Show Devices'),
              ),
              ElevatedButton(
                onPressed: () {
                  model.clear();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: OutputView(scrollController: _scrollController),
          ),
        ],
      ),
    );
  }
}
