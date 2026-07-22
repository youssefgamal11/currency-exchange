import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends CachingAssetBundle {
  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"></svg>';

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(_svg));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _svg;
}

Future<void> pumpWithHarness(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: child,
        builder: (context, screenChild) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: screenChild),
        ),
      ),
    ),
  );
}
