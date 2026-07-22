import 'package:axis/core%20/services/error/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/exchange_rates_result.dart';
import '../../domain/repository/exchange_rates_repository.dart';
import '../data_source/exchange_rates_local_data_source.dart';
import '../data_source/exchange_rates_remote_data_source.dart';

@Injectable(as: ExchangeRateRepository)
class ExchangeRateRepositoryImpl extends ExchangeRateRepository {
  final ExchangeRateRemoteDataSource exchangeRateRemoteDataSource;
  final ExchangeRateLocalDataSource exchangeRateLocalDataSource;

  ExchangeRateRepositoryImpl({
    required this.exchangeRateRemoteDataSource,
    required this.exchangeRateLocalDataSource,
  });

  @override
  Future<Either<String, ExchangeRatesResult>> getExchangeRates(
    DateTime? dateTime,
  ) async {
    try {
      final response = await exchangeRateRemoteDataSource.getExchangeRates(dateTime);
      // Write-through: persist the fresh response for offline use.
      await exchangeRateLocalDataSource.cacheExchangeRates(dateTime, response);
      return Right(
        ExchangeRatesResult(
          data: response,
          timestamp: DateTime.now(),
          isFromCache: false,
        ),
      );
    } catch (e) {
      // Read-through: fall back to cache when the network call fails.
      final cached = exchangeRateLocalDataSource.getCachedExchangeRates(dateTime);
      if (cached != null) {
        return Right(
          ExchangeRatesResult(
            data: cached.data,
            timestamp: cached.cachedAt,
            isFromCache: true,
          ),
        );
      }
      return Left(ErrorHandler.handle(e).failure.message);
    }
  }
}
