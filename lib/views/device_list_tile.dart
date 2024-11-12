import 'package:adb_tools/data/models/device.dart';
import 'package:flutter/material.dart';

class DeviceListTile extends StatelessWidget {
  final DeviceInfo device;
  final Function()? onTap;
  final Function()? onConnect;
  final Function()? onDisconnect;
  final Function()? onDelete;
  final bool isSelected;

  const DeviceListTile({
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

    var normalBoxDecoration = BoxDecoration(
      border: Border.all(
          color: Colors.grey,
          width: 1),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
    );

    var disconnectedBoxDecoration = BoxDecoration(
      border: Border.all(
          color: Colors.grey,
          width: 1),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      color: Colors.grey.withOpacity(0.1),
    );

    var selectedBoxDecoration = BoxDecoration(
      border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: MouseRegion(
        cursor: device.connected ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: (){
            if(device.connected) {
              onTap!();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: device.connected ? (isSelected ? selectedBoxDecoration : normalBoxDecoration) : disconnectedBoxDecoration,
            child: Row(
              children: [
                // serial number
                Expanded(child: Text(device.connected ? '${device.serialNumber}       ${device.product}-${device.model}' :device.serialNumber)),

                if (device.wifi) ...[
                  if(!device.connected)...[
                    // button to connect
                    OutlinedButton(
                        onPressed: onConnect, child: const Icon(Icons.link)),
                    const SizedBox(width: 8),
                  ] else ...[
                    // button to disconnect
                    OutlinedButton(
                        onPressed: onDisconnect,
                        child: const Icon(Icons.link_off)),
                    const SizedBox(width: 8),
                  ]
                ],

                if (device.id > 0) ...[
                  // button to delete history
                  OutlinedButton(
                      onPressed: onDelete,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
