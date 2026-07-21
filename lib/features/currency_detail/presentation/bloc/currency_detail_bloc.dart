import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:axis/core%20/enums/bloc_status.dart';
import '../../../exchange_rates/domain/entity/exchange_rates_response_entity.dart';
import '../../../exchange_rates/domain/use_cases/get_exchange_rates_use_case.dart';
import '../../domain/entity/currency_history_point.dart';
import 'currency_detail_events.dart';
import 'currency_detail_states.dart';

@injectable
class CurrencyDetailBloc extends Bloc<CurrencyDetailEvents, CurrencyDetailStates> {
  CurrencyDetailBloc(this.getExchangeRatesUseCase) : super(const CurrencyDetailStates()) {
    on<GetCurrencyHistoryEvent>(getCurrencyHistory);
  }

  final GetExchangeRatesUseCase getExchangeRatesUseCase;

  Future<void> getCurrencyHistory(
    GetCurrencyHistoryEvent event,
    Emitter<CurrencyDetailStates> emit,
  ) async {
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
          responses.add(response);
        },
      );
      if (error != null) break;
    }

    if (error != null) {
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

    emit(state.copyWith(status: BlocStatus.success, history: history));
  }
}
