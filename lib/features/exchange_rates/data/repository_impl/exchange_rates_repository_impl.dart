import 'package:axis/core%20/services/error/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/exchange_rates_response_entity.dart';
import '../../domain/repository/exchange_rates_repository.dart';
import '../data_source/exchange_rates_remote_data_source.dart';

@Injectable(as: ExchangeRateRepository)
class ExchangeRateRepositoryImpl extends ExchangeRateRepository {
  final ExchangeRateRemoteDataSource exchangeRateRemoteDataSource;
  ExchangeRateRepositoryImpl({required this.exchangeRateRemoteDataSource});

  @override
  Future<Either<String, ExchangeRateResponseEntity>> getExchangeRates(DateTime? dateTime) async {
    try {
      final response = await exchangeRateRemoteDataSource.getExchangeRates(dateTime);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure.message);
    }
  }
}
