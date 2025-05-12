import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const MyTextFormField({
    super.key,
    required this.hintText,
    this.validator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            controller!.clear();
          },
        ),
      ),
      validator: validator,
    );
  }
}
