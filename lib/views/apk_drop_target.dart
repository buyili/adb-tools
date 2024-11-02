import 'package:adb_tools/utils/dialog_utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../data/models/device.dart';

class ApkDragTarget extends StatefulWidget {
  final List<XFile> list;
  final Device? targetDevice;
  final Function() onInstall;

  const ApkDragTarget({
    super.key,
    required this.list,
    required this.onInstall,
    this.targetDevice,
  });

  @override
  _ApkDragTargetState createState() => _ApkDragTargetState();
}

class _ApkDragTargetState extends State<ApkDragTarget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Drag and drop APK files here"),
                Row(
                  children: [
                    Text(
                      "Selected device: ${widget.targetDevice?.host ?? "None"}",
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: (widget.targetDevice != null &&
                              widget.list.isNotEmpty)
                          ? widget.onInstall
                          : null,
                      child: const Text("Install"),
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
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: widget.list.isEmpty
                  ? const Center(child: Text("Drop APK files here"))
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
