import 'package:axis/features/exchange_rates/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entity/exchange_rate_response_entity.dart';

@injectable
class GetExchangeRatesUseCase {
  final ExchangeRateRepository exchangeRateRepository;
  GetExchangeRatesUseCase({required this.exchangeRateRepository});
  Future<Either<String, ExchangeRateResponseEntity>> call(DateTime ?dateTime) async {
    return await exchangeRateRepository.getExchangeRates(dateTime);
  }
}
