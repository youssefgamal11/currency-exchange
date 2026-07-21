import 'package:axis/features/onBoarding/presenation/pages/onBoarding_page.dart';
import 'package:axis/features/exchange_rate_list/presentation/pages/exchange_rate_list_page.dart';
import 'package:flutter/material.dart';

import 'route_name.dart';


class AppRouter {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {

      case RouteName.onBoarding:
        return MaterialPageRoute(
          builder: (_) =>
           const OnboardingPage(),
        );

      case RouteName.exchangeRateList:
        return MaterialPageRoute(
          builder: (_) =>
           const ExchangeRateListPage(),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SizedBox());
    }
  }
}