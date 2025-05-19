class CommandExample {
  String args;
  bool needDevice;
  CommandExample(this.args, this.needDevice);

  factory CommandExample.fromJson(Map<String, dynamic> json) {
    return CommandExample(
      json['args'] as String,
      json['needDevice'] as bool,
    );
  }
}
