import 'package:axis/features/onBoarding/presenation/pages/onBoarding_page.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_events.dart';
import 'package:axis/features/exchange_rates/presentation/pages/exchange_rates_page.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_events.dart';
import 'package:axis/features/currency_detail/presentation/args/currency_detail_args.dart';
import 'package:axis/features/currency_detail/presentation/pages/currency_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/service_locator.dart/service_locator.dart';
import 'route_name.dart';
import 'smooth_page_route.dart';

class AppRouter {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {

      case RouteName.onBoarding:
        return SmoothPageRoute(
          settings: settings,
          child: const OnboardingPage(),
        );

      case RouteName.exchangeRateListPage:
        return SmoothPageRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => sl<ExchangeRateBloc>()..add(const GetExchangeRatesEvent()),
            child: const ExchangeRateListPage(),
          ),
        );

      case RouteName.currencyDetail:
        final args = settings.arguments as CurrencyDetailArgs;
        return SmoothPageRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => sl<CurrencyDetailBloc>()..add(GetCurrencyHistoryEvent(code: args.code)),
            child: CurrencyDetailPage(args: args),
          ),
        );

      default:
        return SmoothPageRoute(child: const SizedBox());
    }
  }
}
