import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:axis/core%20/enums/bloc_status.dart';
import '../../domain/use_cases/get_exchange_rates_use_case.dart';
import '../models/exchange_rate_view_data.dart';
import 'exchange_rate_events.dart';
import 'exchange_rate_states.dart';

@injectable
class ExchangeRateBloc extends Bloc<ExchangeRateEvents, ExchangeRateStates> {
  ExchangeRateBloc(this.getExchangeRatesUseCase)
    : super(const ExchangeRateStates()) {
    on<GetExchangeRateEvent>(getExchangeRateList);
  }

  final GetExchangeRatesUseCase getExchangeRatesUseCase;

  Future<void> getExchangeRateList(
    GetExchangeRateEvent event,
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
        (previous) => ExchangeRateViewData.build(latest: latest, previous: previous),
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
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }
}
