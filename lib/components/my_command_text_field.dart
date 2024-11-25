import 'package:flutter/material.dart';

class MyCommandTextField extends StatelessWidget {
  final TextEditingController controller;

  const MyCommandTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 200.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          SizedBox(
            height: 150,
            width: 1000, // your scroll width
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              scrollPhysics: const ScrollPhysics(),
              expands: true,
              maxLines: null,
              decoration: const InputDecoration(hintText: 'hint'),
              validator: (value) {
                if (value!.isEmpty) return 'No Blank';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
