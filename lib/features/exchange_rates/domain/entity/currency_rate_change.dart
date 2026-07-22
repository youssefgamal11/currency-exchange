import 'exchange_rates_response_entity.dart';

enum RateTrend { strengthening, weakening, unchanged }

const kSupportedCurrencyCodes = ['USD', 'EUR', 'GBP', 'SAR', 'JPY'];

class CurrencyRateChange {
  const CurrencyRateChange({
    required this.code,
    required this.rate,
    required this.changeAbsolute,
    required this.changePercent,
    required this.trend,
  });

  final String code;
  final double rate;
  final double changeAbsolute;
  final double changePercent;
  final RateTrend trend;

  factory CurrencyRateChange.fromQuotes({
    required String code,
    required double todayQuote,
    double? yesterdayQuote,
  }) {
    final rate = 1 / todayQuote;
    final previousRate = (yesterdayQuote == null || yesterdayQuote == 0)
        ? rate
        : 1 / yesterdayQuote;
    final changeAbsolute = rate - previousRate;
    final changePercent =
        previousRate == 0 ? 0.0 : (changeAbsolute / previousRate) * 100;
    final trend = changeAbsolute < 0
        ? RateTrend.strengthening
        : changeAbsolute > 0
            ? RateTrend.weakening
            : RateTrend.unchanged;

    return CurrencyRateChange(
      code: code,
      rate: rate,
      changeAbsolute: changeAbsolute,
      changePercent: changePercent,
      trend: trend,
    );
  }

  static List<CurrencyRateChange> fromResponses({
    required ExchangeRateResponseEntity latest,
    required ExchangeRateResponseEntity previous,
  }) {
    return kSupportedCurrencyCodes
        .where((code) => (latest.egp?[code] ?? 0) != 0)
        .map(
          (code) => CurrencyRateChange.fromQuotes(
            code: code,
            todayQuote: latest.egp![code]!,
            yesterdayQuote: previous.egp?[code],
          ),
        )
        .toList();
  }
}
