import 'package:adb_tools/components/copyable_text.dart';
import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/models/scrcpy_related/scrcpy_config.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:adb_tools/utils/scrspy_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceListTile extends ConsumerWidget {
  final DeviceInfo device;
  final Function()? onTap;
  final Function()? onOpenTcpipPort;
  final Function()? onConnect;
  final Function()? onDisconnect;
  final Function()? onDelete;
  final Function()? onGetIpAndConnect;
  final bool isSelected;

  const DeviceListTile({
    super.key,
    required this.device,
    this.onTap,
    this.onOpenTcpipPort,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    this.isSelected = false,
    this.onGetIpAndConnect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var border = Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 1));
    var normalBoxDecoration = BoxDecoration(
      border: border,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.8)
          : null,
    );

    var disconnectedBoxDecoration = BoxDecoration(
      border: border,
      color: null,
    );

    var selectedBoxDecoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: colorScheme.outline, width: 1)),
      color: colorScheme.primary.withValues(alpha: 0.2),
    );

    Icon renderLeadingIcon() {
      if (device.connected) {
        return device.wifi
            ? const Icon(
                Icons.wifi,
              )
            : const Icon(Icons.usb);
      }
      return const Icon(Icons.wifi_off);
    }

    void onStartScrcpy() {
      final ScrcpyConfig config = ref.read(configScreenConfig)!;
      ScrcpyUtils.start(device.serialNumber, config);
    }

    return MouseRegion(
      cursor: device.connected ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: () {
          if (device.connected) {
            onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: device.connected
              ? (isSelected ? selectedBoxDecoration : normalBoxDecoration)
              : disconnectedBoxDecoration,
          child: Row(
            children: [
              // icon
              renderLeadingIcon(),
              const SizedBox(
                width: 8,
              ),
    
              // serial number
              Expanded(child: TileTitle(device: device)),
    
              if (!device.wifi) ...[
                OutlinedButton(
                    onPressed: onOpenTcpipPort,
                    child: const Text('Open TCP/IP')),
    
                const SizedBox(width: 8),
    
                // button to connect
                IconButton.outlined(
                  onPressed: onGetIpAndConnect,
                  icon: const Icon(Icons.wifi),
                  color: colorScheme.primary,
                ),
    
                const SizedBox(width: 8),
              ],
    
              if (device.connected) ...[
                // button to disconnect
                IconButton.outlined(
                    onPressed: onStartScrcpy,
                    icon: const Icon(Icons.display_settings)),
                const SizedBox(width: 8),
              ],
    
              if (device.wifi) ...[
                if (!device.connected) ...[
                  // button to connect
                  IconButton.outlined(
                    onPressed: onConnect,
                    icon: const Icon(Icons.link),
                  ),
                  const SizedBox(width: 8),
                ],
                if (device.connected ||
                    DeviceState.offline.name == device.state) ...[
                  // button to disconnect
                  IconButton.filled(
                      onPressed: onDisconnect,
                      icon: const Icon(Icons.link_off)),
                  const SizedBox(width: 8),
                ]
              ],
    
              if (device.isHistory) ...[
                // button to delete history
                IconButton.outlined(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class TileTitle extends StatelessWidget {
  final DeviceInfo device;

  const TileTitle({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CopyableText(device.serialNumber),
        const SizedBox(width: 32),
        CopyableText((device.product != null && device.product!.isNotEmpty)
            ? '${device.product}-${device.model}'
            : '')
      ],
    );
  }
}
