import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_events.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_states.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockGetExchangeRatesUseCase useCase;
  late MockConnectivityService connectivity;

  setUp(() {
    useCase = MockGetExchangeRatesUseCase();
    connectivity = MockConnectivityService();
    stubConnectivity(connectivity);
  });

  ExchangeRateBloc build() => ExchangeRateBloc(useCase, connectivity);

  blocTest<ExchangeRateBloc, ExchangeRateStates>(
    'emits [loading, success] with a populated list and lastUpdated',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => Right(buildResult()));
    },
    build: build,
    act: (bloc) => bloc.add(const GetExchangeRatesEvent()),
    expect: () => [
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.success)
          .having((s) => s.exchangeRateList, 'list', isNotEmpty)
          .having((s) => s.lastUpdated, 'lastUpdated', isNotNull),
    ],
  );

  blocTest<ExchangeRateBloc, ExchangeRateStates>(
    'emits [loading, failure] with the error message when a call fails',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => const Left('network down'));
    },
    build: build,
    act: (bloc) => bloc.add(const GetExchangeRatesEvent()),
    expect: () => [
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'network down'),
    ],
  );

  blocTest<ExchangeRateBloc, ExchangeRateStates>(
    'ConnectivityChangedEvent(false) marks the state offline',
    build: build,
    act: (bloc) => bloc.add(const ConnectivityChangedEvent(false)),
    expect: () => [
      isA<ExchangeRateStates>().having((s) => s.isOffline, 'isOffline', true),
    ],
  );

  blocTest<ExchangeRateBloc, ExchangeRateStates>(
    'auto-refreshes when connectivity returns after being offline',
    setUp: () {
      when(() => useCase(any()))
          .thenAnswer((_) async => Right(buildResult()));
    },
    build: build,
    seed: () => const ExchangeRateStates(isOffline: true),
    act: (bloc) => bloc.add(const ConnectivityChangedEvent(true)),
    expect: () => [
      isA<ExchangeRateStates>().having((s) => s.isOffline, 'isOffline', false),
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.loading),
      isA<ExchangeRateStates>()
          .having((s) => s.status, 'status', BlocStatus.success),
    ],
    verify: (_) {
      verify(() => useCase(any())).called(2);
    },
  );
}
