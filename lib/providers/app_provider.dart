import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final execDirProvider = StateProvider((ref) => '');

String workDir = '';


final filesProvider = StateProvider<List<XFile>>((ref) => []);
