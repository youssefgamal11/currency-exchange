import 'package:equatable/equatable.dart';

import 'package:axis/core%20/enums/bloc_status.dart';

import '../models/exchange_rates_view_data.dart';

class ExchangeRateStates extends Equatable {
  const ExchangeRateStates({
    this.status = BlocStatus.initial,
    this.exchangeRateList = const [],
    this.lastUpdated,
    this.errorMessage,
    this.isOffline = false,
  });

  final BlocStatus status;
  final List<ExchangeRateViewData> exchangeRateList;
  final DateTime? lastUpdated;
  final String? errorMessage;
  final bool isOffline;

  ExchangeRateStates copyWith({
    BlocStatus? status,
    List<ExchangeRateViewData>? exchangeRateList,
    DateTime? lastUpdated,
    String? errorMessage,
    bool? isOffline,
  }) {
    return ExchangeRateStates(
      status: status ?? this.status,
      exchangeRateList: exchangeRateList ?? this.exchangeRateList,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [status, exchangeRateList, lastUpdated, errorMessage, isOffline];
}
