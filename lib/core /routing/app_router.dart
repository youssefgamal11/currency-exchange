import 'package:axis/features/onBoarding/presenation/pages/onBoarding_page.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_events.dart';
import 'package:axis/features/exchange_rates/presentation/pages/exchange_rates_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/service_locator.dart/service_locator.dart';
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
          builder: (_) => BlocProvider(
            create: (_) => sl<ExchangeRateBloc>()..add(const GetExchangeRatesEvent()),
            child: const ExchangeRateListPage(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SizedBox());
    }
  }
}