import 'package:axis/features/exchange_rates/domain/repository/exchange_rates_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entity/exchange_rates_result.dart';

@injectable
class GetExchangeRatesUseCase {
  final ExchangeRateRepository exchangeRateRepository;
  GetExchangeRatesUseCase({required this.exchangeRateRepository});
  Future<Either<String, ExchangeRatesResult>> call(DateTime ?dateTime) async {
    return await exchangeRateRepository.getExchangeRates(dateTime);
  }
}
