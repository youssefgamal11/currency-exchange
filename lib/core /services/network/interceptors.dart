import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,2000}');
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
}

class LanguageAndContentTypeInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    options.headers['Accept-Language'] = 'ar';
    return handler.next(options);
  }
}
