import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/core%20/services/connectivity/connectivity_service.dart';
import '../../domain/entity/currency_rate_change.dart';
import '../../domain/use_cases/get_exchange_rates_use_case.dart';
import '../models/exchange_rates_view_data.dart';
import 'exchange_rates_events.dart';
import 'exchange_rates_states.dart';

@injectable
class ExchangeRateBloc extends Bloc<ExchangeRateEvents, ExchangeRateStates> {
  ExchangeRateBloc(this.getExchangeRatesUseCase, this.connectivityService)
    : super(const ExchangeRateStates()) {
    on<GetExchangeRatesEvent>(getExchangeRateList);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);

    _connectivitySub = connectivityService.onStatusChange.listen(
      (isOnline) => add(ConnectivityChangedEvent(isOnline)),
    );
    connectivityService.isConnected().then(
      (isOnline) => add(ConnectivityChangedEvent(isOnline)),
    );
  }

  final GetExchangeRatesUseCase getExchangeRatesUseCase;
  final ConnectivityService connectivityService;
  StreamSubscription<bool>? _connectivitySub;

  Future<void> getExchangeRateList(
    GetExchangeRatesEvent event,
    Emitter<ExchangeRateStates> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final results = await Future.wait([
      getExchangeRatesUseCase(null),
      getExchangeRatesUseCase(yesterday),
    ]);

    final latestResult = results[0];
    final previousResult = results[1];

    final combined = latestResult.flatMap(
      (latest) => previousResult.map(
        (previous) => CurrencyRateChange.fromResponses(
          latest: latest.data,
          previous: previous.data,
        ).map(ExchangeRateViewData.fromChange).toList(),
      ),
    );

    combined.fold(
      (error) {
        emit(state.copyWith(status: BlocStatus.failure, errorMessage: error));
      },
      (list) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            exchangeRateList: list,
            lastUpdated: latestResult.fold((_) => state.lastUpdated, (r) => r.timestamp),
          ),
        );
      },
    );
  }

  void _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<ExchangeRateStates> emit,
  ) {
    final wasOffline = state.isOffline;
    if (kDebugMode) {
      debugPrint('[ExchangeRateBloc] connectivity handler: '
          'isOnline=${event.isOnline}, wasOffline=$wasOffline');
    }
    emit(state.copyWith(isOffline: !event.isOnline));

    if (wasOffline && event.isOnline) {
      add(const GetExchangeRatesEvent());
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
