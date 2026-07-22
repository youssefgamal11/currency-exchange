import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/core%20/services/connectivity/connectivity_service.dart';
import '../../../exchange_rates/domain/entity/exchange_rates_response_entity.dart';
import '../../../exchange_rates/domain/use_cases/get_exchange_rates_use_case.dart';
import '../../data/data_source/currency_history_local_data_source.dart';
import '../../domain/entity/currency_history_point.dart';
import 'currency_detail_events.dart';
import 'currency_detail_states.dart';

@injectable
class CurrencyDetailBloc extends Bloc<CurrencyDetailEvents, CurrencyDetailStates> {
  CurrencyDetailBloc(
    this.getExchangeRatesUseCase,
    this.connectivityService,
    this.historyLocalDataSource,
  ) : super(const CurrencyDetailStates()) {
    on<GetCurrencyHistoryEvent>(getCurrencyHistory);
    on<ConnectivityChangedEvent>(onConnectivityChanged);

    connectivitySub = connectivityService.onStatusChange.listen(
      (isOnline) => add(ConnectivityChangedEvent(isOnline)),
    );
    connectivityService.isConnected().then(
      (isOnline) => add(ConnectivityChangedEvent(isOnline)),
    );
  }

  final GetExchangeRatesUseCase getExchangeRatesUseCase;
  final ConnectivityService connectivityService;
  final CurrencyHistoryLocalDataSource historyLocalDataSource;
  StreamSubscription<bool>? connectivitySub;
  String? _lastCode;

  Future<void> getCurrencyHistory(
    GetCurrencyHistoryEvent event,
    Emitter<CurrencyDetailStates> emit,
  ) async {
    _lastCode = event.code;
    emit(state.copyWith(status: BlocStatus.loading));

    final now = DateTime.now();
    final results = await Future.wait([
      for (var i = 6; i >= 1; i--) getExchangeRatesUseCase(now.subtract(Duration(days: i))),
      getExchangeRatesUseCase(null),
    ]);

    String? error;
    final responses = <ExchangeRateResponseEntity>[];
    for (final result in results) {
      result.fold(
        (e) {
          error ??= e;
        },
        (response) {
          responses.add(response.data);
        },
      );
      if (error != null) break;
    }

    if (error != null) {
      final cached = historyLocalDataSource.getCachedHistory(event.code);
      if (cached != null && cached.isNotEmpty) {
        emit(state.copyWith(status: BlocStatus.success, history: cached));
        return;
      }
      emit(state.copyWith(status: BlocStatus.failure, errorMessage: error));
      return;
    }

    final history = <CurrencyHistoryPoint>[];
    for (var i = 0; i < responses.length; i++) {
      final rawQuote = responses[i].egp?[event.code];
      if (rawQuote == null || rawQuote == 0) continue;
      history.add(
        CurrencyHistoryPoint(date: now.subtract(Duration(days: 6 - i)), rate: 1 / rawQuote),
      );
    }

    if (!state.isOffline) {
      await historyLocalDataSource.cacheHistory(event.code, history);
    }

    emit(state.copyWith(status: BlocStatus.success, history: history));
  }

  void onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<CurrencyDetailStates> emit,
  ) {
    final wasOffline = state.isOffline;
    emit(state.copyWith(isOffline: !event.isOnline));

    if (wasOffline && event.isOnline && _lastCode != null) {
      add(GetCurrencyHistoryEvent(code: _lastCode!));
    }
  }

  @override
  Future<void> close() {
    connectivitySub?.cancel();
    return super.close();
  }
}
