import 'package:axis/core%20/services/connectivity/connectivity_service.dart';
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
  final ConnectivityService connectivityService;

  ExchangeRateRepositoryImpl({
    required this.exchangeRateRemoteDataSource,
    required this.exchangeRateLocalDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<String, ExchangeRatesResult>> getExchangeRates(
    DateTime? dateTime,
  ) async {
    // Offline: never fire the request, serve cache when available.
    if (!await connectivityService.isConnected()) {
      return _cachedOr(dateTime, 'No internet connection');
    }

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
      return _cachedOr(dateTime, ErrorHandler.handle(e).failure.message);
    }
  }

  Either<String, ExchangeRatesResult> _cachedOr(
    DateTime? dateTime,
    String fallbackError,
  ) {
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
    return Left(fallbackError);
  }
}
