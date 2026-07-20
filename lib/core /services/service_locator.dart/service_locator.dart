import 'package:get_it/get_it.dart' show GetIt;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'serivice_locator.config.dart';

/// sl -> Service Locator
final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureInjection() => sl.init();

