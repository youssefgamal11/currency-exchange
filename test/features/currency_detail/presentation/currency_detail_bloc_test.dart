import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/features/currency_detail/domain/entity/currency_history_point.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_events.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_states.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerCommonFallbacks();
    registerFallbackValue(<CurrencyHistoryPoint>[]);
  });

  late MockGetExchangeRatesUseCase useCase;
  late MockConnectivityService connectivity;
  late MockCurrencyHistoryLocalDataSource history;

  setUp(() {
    useCase = MockGetExchangeRatesUseCase();
    connectivity = MockConnectivityService();
    history = MockCurrencyHistoryLocalDataSource();
    stubConnectivity(connectivity);
    when(() => history.cacheHistory(any(), any())).thenAnswer((_) async {});
  });

  CurrencyDetailBloc build() =>
      CurrencyDetailBloc(useCase, connectivity, history);

  blocTest<CurrencyDetailBloc, CurrencyDetailStates>(
    'builds a 7-point history (rate = 1/quote) and caches it when online',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => Right(buildResult(data: buildResponse(usd: 48))));
    },
    build: build,
    act: (bloc) => bloc.add(const GetCurrencyHistoryEvent(code: 'USD')),
    expect: () => [
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.success)
          .having((s) => s.history.length, 'history length', 7)
          .having((s) => s.history.first.rate, 'rate', closeTo(1 / 48, 1e-12)),
    ],
    verify: (_) {
      verify(() => useCase(any())).called(7);
      verify(() => history.cacheHistory('USD', any())).called(1);
    },
  );

  blocTest<CurrencyDetailBloc, CurrencyDetailStates>(
    'falls back to cached history when a call fails and cache is present',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => const Left('offline'));
      when(() => history.getCachedHistory('USD')).thenReturn([
        CurrencyHistoryPoint(date: DateTime(2026, 7, 20), rate: 0.02),
      ]);
    },
    build: build,
    act: (bloc) => bloc.add(const GetCurrencyHistoryEvent(code: 'USD')),
    expect: () => [
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.success)
          .having((s) => s.history.length, 'history length', 1),
    ],
  );

  blocTest<CurrencyDetailBloc, CurrencyDetailStates>(
    'emits failure when a call fails and there is no cache',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => const Left('offline'));
      when(() => history.getCachedHistory(any())).thenReturn(null);
    },
    build: build,
    act: (bloc) => bloc.add(const GetCurrencyHistoryEvent(code: 'USD')),
    expect: () => [
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<CurrencyDetailStates>()
          .having((s) => s.status, 'status', BlocStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'offline'),
    ],
  );

  blocTest<CurrencyDetailBloc, CurrencyDetailStates>(
    'does not cache history while offline',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => Right(buildResult()));
    },
    build: build,
    seed: () => const CurrencyDetailStates(isOffline: true),
    act: (bloc) => bloc.add(const GetCurrencyHistoryEvent(code: 'USD')),
    verify: (_) {
      verifyNever(() => history.cacheHistory(any(), any()));
    },
  );
}
