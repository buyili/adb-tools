// top form
import 'package:adb_tools/components/my_text_form_field.dart';
import 'package:flutter/material.dart';

const String defaultPort = '5555';

class TopForm extends StatefulWidget {
  final Function onSubmit;
  final Function onSave;

  const TopForm({
    super.key,
    required this.onSubmit,
    required this.onSave,
  });

  @override
  State<TopForm> createState() => _TopFormState();
}

class _TopFormState extends State<TopForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  List<String> getIpAndPort() {
    var ip = '';
    var port = '';
    if (_ipController.text.contains(':')) {
      ip = _ipController.text.split(':')[0];
      port = _ipController.text.split(':')[1];
    } else {
      ip = _ipController.text;
      port =
          _portController.text.isNotEmpty ? _portController.text : defaultPort;
    }
    return [ip, port];
  }

  void _toggleConnect() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(getIpAndPort()[0], getIpAndPort()[1]);
    }
  }

  void _toggleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(getIpAndPort()[0], getIpAndPort()[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          // in text field
          SizedBox(
            width: 220,
            child: MyTextFormField(
              controller: _ipController,
              hintText: 'ip or ip:port',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ip address.';
                }
                return null;
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              ':',
              style: TextStyle(fontSize: 24.0),
            ),
          ),

          // port text field
          SizedBox(
            width: 120,
            child: MyTextFormField(
              controller: _portController,
              hintText: defaultPort,
            ),
          ),

          const SizedBox(width: 10.0),

          // connect button
          FilledButton.icon(
            onPressed: () {
              _toggleConnect();
            },
            icon: const Icon(Icons.link),
            label: const Text('Connect'),
          ),

          const SizedBox(width: 10.0),

          // save button
          FilledButton.icon(
            onPressed: () {
              _toggleSave();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
