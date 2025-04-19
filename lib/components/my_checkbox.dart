import 'package:flutter/material.dart';

class MyCheckbox extends StatelessWidget {
  const MyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.child,
  });

  final bool value;
  final Widget? child;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        if (child != null) child!,
      ],
    );
  }
}
