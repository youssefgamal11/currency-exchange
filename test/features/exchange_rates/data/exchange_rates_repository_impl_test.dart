import 'package:axis/features/exchange_rates/data/data_source/exchange_rates_local_data_source.dart';
import 'package:axis/features/exchange_rates/data/repository_impl/exchange_rates_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerCommonFallbacks();
    registerFallbackValue(buildResponse());
  });

  late MockExchangeRateRemoteDataSource remote;
  late MockExchangeRateLocalDataSource local;
  late MockConnectivityService connectivity;
  late ExchangeRateRepositoryImpl repository;

  setUp(() {
    remote = MockExchangeRateRemoteDataSource();
    local = MockExchangeRateLocalDataSource();
    connectivity = MockConnectivityService();
    repository = ExchangeRateRepositoryImpl(
      exchangeRateRemoteDataSource: remote,
      exchangeRateLocalDataSource: local,
      connectivityService: connectivity,
    );
  });

  group('offline', () {
    setUp(() {
      when(() => connectivity.isConnected()).thenAnswer((_) async => false);
    });

    test('serves cache without hitting the network', () async {
      final cachedAt = DateTime(2026, 7, 20, 8);
      when(() => local.getCachedExchangeRates(any())).thenReturn(
        CachedExchangeRates(data: buildResponse(), cachedAt: cachedAt),
      );

      final either = await repository.getExchangeRates(null);

      final result = either.getOrElse(() => throw StateError('expected Right'));
      expect(result.isFromCache, isTrue);
      expect(result.timestamp, cachedAt);
      verifyNever(() => remote.getExchangeRates(any()));
    });

    test('returns Left when no cache exists', () async {
      when(() => local.getCachedExchangeRates(any())).thenReturn(null);

      final either = await repository.getExchangeRates(null);

      expect(either, const Left<String, dynamic>('No internet connection'));
    });
  });

  group('online', () {
    setUp(() {
      when(() => connectivity.isConnected()).thenAnswer((_) async => true);
    });

    test('fetches fresh data and writes it through to cache', () async {
      final response = buildResponse();
      when(() => remote.getExchangeRates(any()))
          .thenAnswer((_) async => response);
      when(() => local.cacheExchangeRates(any(), any()))
          .thenAnswer((_) async {});

      final either = await repository.getExchangeRates(null);

      final result = either.getOrElse(() => throw StateError('expected Right'));
      expect(result.isFromCache, isFalse);
      expect(result.data, response);
      verify(() => local.cacheExchangeRates(null, response)).called(1);
    });

    test('falls back to cache when the remote call throws', () async {
      final cachedAt = DateTime(2026, 7, 19);
      when(() => remote.getExchangeRates(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );
      when(() => local.getCachedExchangeRates(any())).thenReturn(
        CachedExchangeRates(data: buildResponse(), cachedAt: cachedAt),
      );

      final either = await repository.getExchangeRates(null);

      final result = either.getOrElse(() => throw StateError('expected Right'));
      expect(result.isFromCache, isTrue);
      expect(result.timestamp, cachedAt);
    });

    test('returns Left(errorMessage) when remote throws and no cache', () async {
      when(() => remote.getExchangeRates(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/')),
      );
      when(() => local.getCachedExchangeRates(any())).thenReturn(null);

      final either = await repository.getExchangeRates(null);

      expect(either.isLeft(), isTrue);
      either.fold(
        (msg) => expect(msg, isNotEmpty),
        (_) => fail('expected Left'),
      );
    });
  });
}
