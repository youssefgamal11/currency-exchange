import 'package:axis/features/exchange_rates/data/models/exchange_rates_response_model.dart';
import 'package:axis/features/exchange_rates/domain/entity/exchange_rates_result.dart';

ExchangeRateResponseModel buildResponse({
  String date = '2026-07-22',
  double usd = 48.0,
  double eur = 52.0,
  double gbp = 61.0,
  double sar = 12.8,
  double jpy = 0.33,
}) {
  return ExchangeRateResponseModel.fromJson({
    'date': date,
    'egp': {'usd': usd, 'eur': eur, 'gbp': gbp, 'sar': sar, 'jpy': jpy},
  });
}

ExchangeRatesResult buildResult({
  bool isFromCache = false,
  DateTime? at,
  ExchangeRateResponseModel? data,
}) {
  return ExchangeRatesResult(
    data: data ?? buildResponse(),
    timestamp: at ?? DateTime(2026, 7, 22),
    isFromCache: isFromCache,
  );
}
