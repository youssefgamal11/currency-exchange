import 'exchange_rates_response_entity.dart';

class ExchangeRatesResult {
  const ExchangeRatesResult({
    required this.data,
    required this.timestamp,
    required this.isFromCache,
  });

  final ExchangeRateResponseEntity data;

  final DateTime timestamp;

  final bool isFromCache;
}
