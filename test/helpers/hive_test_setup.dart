import 'dart:io';

import 'package:hive/hive.dart';

class TempHive {
  late Directory _dir;

  Future<Box> open(String boxName) async {
    _dir = await Directory.systemTemp.createTemp('axis_hive_test');
    Hive.init(_dir.path);
    return Hive.openBox(boxName);
  }

  Future<void> close() async {
    await Hive.deleteFromDisk();
    if (await _dir.exists()) {
      await _dir.delete(recursive: true);
    }
  }
}
