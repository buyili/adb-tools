import 'package:adb_tools/utils/dialog_utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../data/models/device.dart';

class ApkDragTarget extends StatefulWidget {
  final List<XFile> list;
  final DeviceInfo? targetDevice;
  final Function() onStartShizuku;
  final Function() onInstall;
  final Function() onPush;
  final Function() onClearAll;

  const ApkDragTarget({
    super.key,
    required this.list,
    required this.onInstall,
    required this.onPush,
    this.targetDevice,
    required this.onClearAll, required this.onStartShizuku,
  });

  @override
  State<ApkDragTarget> createState() => _ApkDragTargetState();
}

class _ApkDragTargetState extends State<ApkDragTarget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    var isSelectedDevice = (widget.targetDevice != null);
    var isSelectedDeviceAndFiles =
        (widget.targetDevice != null && widget.list.isNotEmpty);
    return DropTarget(
      onDragDone: (detail) {
        var files = detail.files.where((file) {
          return !widget.list.any((item) {
            return item.path == file.path;
          });
        }).toList();
        if (files.isEmpty) {
          DialogUtils.showInfoDialog(
            context,
            "No new APK files were dropped",
            "You can only drop APK files that are not already selected",
          );
          return;
        }
        setState(() {
          widget.list.addAll(files);
        });
      },
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
      child: Container(
        margin: const EdgeInsets.only(right: 16),
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
                      widget.targetDevice?.serialNumber ?? "None",
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSelectedDevice ? widget.onStartShizuku : null,
                      child: const Text("Start Shizuku"),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSelectedDeviceAndFiles ? widget.onInstall : null,
                      child: const Text("Install"),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: isSelectedDeviceAndFiles ? widget.onPush : null,
                      child: const Text("Push"),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed:
                          (widget.list.isNotEmpty) ? widget.onClearAll : null,
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
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              child: widget.list.isEmpty
                  ? const Center(
                      child: Text("Drag and drop APK or other files here"))
                  : ListView.builder(
                      itemCount: widget.list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 8.0, right: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.android),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.list[index].name),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          widget.list.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
