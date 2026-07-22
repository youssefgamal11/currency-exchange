import 'dart:async';

import 'package:axis/core%20/services/connectivity/connectivity_service.dart';
import 'package:axis/core%20/services/network/network_helper.dart';
import 'package:axis/features/currency_detail/data/data_source/currency_history_local_data_source.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_events.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_states.dart';
import 'package:axis/features/exchange_rates/data/data_source/exchange_rates_local_data_source.dart';
import 'package:axis/features/exchange_rates/data/data_source/exchange_rates_remote_data_source.dart';
import 'package:axis/features/exchange_rates/domain/repository/exchange_rates_repository.dart';
import 'package:axis/features/exchange_rates/domain/use_cases/get_exchange_rates_use_case.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_events.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_states.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetExchangeRatesUseCase extends Mock
    implements GetExchangeRatesUseCase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockCurrencyHistoryLocalDataSource extends Mock
    implements CurrencyHistoryLocalDataSource {}

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

class MockExchangeRateRemoteDataSource extends Mock
    implements ExchangeRateRemoteDataSource {}

class MockExchangeRateLocalDataSource extends Mock
    implements ExchangeRateLocalDataSource {}

class MockNetworkHelper extends Mock implements NetworkHelper {}

class MockExchangeRateBloc
    extends MockBloc<ExchangeRateEvents, ExchangeRateStates>
    implements ExchangeRateBloc {}

class MockCurrencyDetailBloc
    extends MockBloc<CurrencyDetailEvents, CurrencyDetailStates>
    implements CurrencyDetailBloc {}

void stubConnectivity(MockConnectivityService c) {
  when(() => c.onStatusChange).thenAnswer((_) => const Stream<bool>.empty());
  when(() => c.isConnected()).thenAnswer((_) => Completer<bool>().future);
}

void registerCommonFallbacks() {
  registerFallbackValue(DateTime(2020));
}
