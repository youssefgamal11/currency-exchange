import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';

class CurrencyDetailArgs {
  const CurrencyDetailArgs({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.rate,
    required this.changeAbsolute,
    required this.changePercent,
    required this.trend,
    required this.lastUpdated,
  });

  final String code;
  final String name;
  final String flagAsset;
  final double rate;
  final double changeAbsolute;
  final double changePercent;
  final RateTrend trend;
  final DateTime? lastUpdated;

  double get yesterdayRate => rate - changeAbsolute;
}
