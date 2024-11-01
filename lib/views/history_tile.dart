import 'package:adb_tools/data/models/device.dart';
import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final Device device;
  final Function()? onConnect;
  final Function()? onDisconnect;
  final Function()? onDelete;

  const HistoryTile({
    super.key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          children: [
            // ip address
            Expanded(child: Text('${device.ip}:${device.port}')),

            // button to connect
            OutlinedButton(onPressed: onConnect, child: const Text('connect')),
            const SizedBox(width: 8),
            // button to disconnect
            OutlinedButton(
                onPressed: onDisconnect, child: const Text('disconnect')),
            const SizedBox(width: 8),
            // button to delete history
            OutlinedButton(
                onPressed: onDelete, child: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
