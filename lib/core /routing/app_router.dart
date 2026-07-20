import 'package:axis/features/onBoarding/presenation/pages/onBoarding_page.dart';
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
      
      default:
        return MaterialPageRoute(builder: (_) => const SizedBox());
    }
  }
}