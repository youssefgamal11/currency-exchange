import 'package:dartz/dartz.dart';

import '../entity/exchange_rate_response_entity.dart';

abstract class ExchangeRateRepository {
  Future<Either<String, ExchangeRateResponseEntity>> getExchangeRates(DateTime ?dateTime);

}
