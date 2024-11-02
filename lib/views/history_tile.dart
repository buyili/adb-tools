import 'package:adb_tools/data/models/device.dart';
import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final Device device;
  final Function()? onTap;
  final Function()? onConnect;
  final Function()? onDisconnect;
  final Function()? onDelete;
  final bool isSelected;

  const HistoryTile({
    super.key,
    required this.device,
    this.onTap,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                // ip address
                Expanded(child: Text(device.host)),

                // button to connect
                OutlinedButton(onPressed: onConnect, child: const Icon(Icons.link)),
                const SizedBox(width: 8),
                // button to disconnect
                OutlinedButton(
                    onPressed: onDisconnect, child: const Icon(Icons.link_off)),
                const SizedBox(width: 8),
                // button to delete history
                OutlinedButton(
                    onPressed: onDelete, child: const Icon(Icons.delete, color: Colors.red,)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
