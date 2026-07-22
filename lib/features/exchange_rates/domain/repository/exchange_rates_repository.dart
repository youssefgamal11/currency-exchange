import 'package:dartz/dartz.dart';

import '../entity/exchange_rates_result.dart';

abstract class ExchangeRateRepository {
  Future<Either<String, ExchangeRatesResult>> getExchangeRates(DateTime ?dateTime);

}
