import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  const HiveStorage._();

  static String exchangeRatesCacheBox() => 'exchange_rates_cache';

  static String currencyHistoryBox() => 'currency_history_cache';

  static String appSettingsBox() => 'app_settings';

  static String _onboardingSeenKey() => 'onboarding_seen';

  static Future<void> init() async {
    await Hive.initFlutter();
    await openBox(exchangeRatesCacheBox());
    await openBox(currencyHistoryBox());
    await openBox(appSettingsBox());
  }

  static Future<Box> openBox(String name) async =>
      Hive.isBoxOpen(name) ? Hive.box(name) : await Hive.openBox(name);

  static Box box(String name) => Hive.box(name);

  static bool get hasSeenOnboarding =>
      box(appSettingsBox()).get(_onboardingSeenKey(), defaultValue: false)
          as bool;

  static Future<void> setOnboardingSeen() =>
      box(appSettingsBox()).put(_onboardingSeenKey(), true);
}
