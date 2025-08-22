import 'package:adb_tools/providers/app_provider.dart';
import 'package:adb_tools/utils/dialog_utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/device_list_provider.dart';
import '../../../utils/adb_utils.dart';

class ApkDragTarget extends ConsumerStatefulWidget {
  const ApkDragTarget({
    super.key,
  });

  @override
  ConsumerState<ApkDragTarget> createState() => _ApkDragTargetState();
}

class _ApkDragTargetState extends ConsumerState<ApkDragTarget> {
  bool _dragging = false;

  void _onDropDone(DropDoneDetails details) async {
    var list = ref.read(filesProvider);
    var files = details.files.where((file) {
      return !list.any((item) {
        return item.path == file.path;
      });
    }).toList();
    if (files.isEmpty) {
      DialogUtils.showInfoDialog(
        "No new APK files were dropped",
        "You can only drop APK files that are not already selected",
      );
      return;
    }
    ref.read(filesProvider.notifier).state = [
      ...ref.read(filesProvider),
      ...files
    ];
  }

  // start shizuku
  Future<void> _toggleStartShizuku() async {
    var serialNumber = ref.read(selectedDeviceProvider)!.serialNumber;
    var info = await ADBUtils.getShizukuPackageInfo(serialNumber);
    if (int.parse(info.versionCode) < 1086) {
      ADBUtils.startShizuku(serialNumber);
      return;
    }

    ADBUtils.startShizuku2(serialNumber, info);
  }

  // start brevent
  Future<void> _toggleStartBrevent() async {
    var serialNumber = ref.read(selectedDeviceProvider)!.serialNumber;
    ADBUtils.startBrevent(serialNumber);
  }

  // install apk to device
  void _toggleInstall() {
    var list = ref.read(filesProvider);
    ADBUtils.install(ref.read(selectedDeviceProvider), list);
  }

  // push files to device
  void _togglePushFiles() {
    var list = ref.read(filesProvider);
    ADBUtils.push(ref.read(selectedDeviceProvider), list);
  }

  // clear all files
  void _toggleClearAll() {
    ref.read(filesProvider.notifier).state = [];
  }

  @override
  Widget build(BuildContext context) {
    var selectedDevice = ref.watch(selectedDeviceProvider);
    var isSelectedDevice = (selectedDevice != null);
    var list = ref.watch(filesProvider);
    var isSelectedDeviceAndFiles = (selectedDevice != null && list.isNotEmpty);

    return DropTarget(
      onDragDone: _onDropDone,
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected device:",
                  ),
                  Text(
                    selectedDevice?.serialNumber ?? "None",
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: isSelectedDevice ? _toggleStartShizuku : null,
                    child: const Text("Start Shizuku"),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: isSelectedDevice ? _toggleStartBrevent : null,
                    child: const Text("Start 黑域"),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: isSelectedDeviceAndFiles ? _toggleInstall : null,
                    child: const Text("Install"),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed:
                        isSelectedDeviceAndFiles ? _togglePushFiles : null,
                    child: const Text("Push"),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: (list.isNotEmpty) ? _toggleClearAll : null,
                    child: const Text("Clear All"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: _dragging
                  ? Colors.black26
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: list.isEmpty
                ? const Center(
                    child: Text("Drag and drop APK or other files here"))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return FileListItem(
                        file: list[index],
                        onDelete: () {
                          setState(() {
                            list.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class FileListItem extends StatelessWidget {
  const FileListItem({super.key, required this.file, this.onDelete});
  final XFile file;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 8.0, right: 8),
      child: Row(
        children: [
          const Icon(Icons.android),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        file.path,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    onDelete?.call();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
