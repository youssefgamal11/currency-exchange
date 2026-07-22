import 'dart:math';

import 'package:equatable/equatable.dart';

import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';

import '../../domain/entity/currency_history_point.dart';

class CurrencyDetailStates extends Equatable {
  const CurrencyDetailStates({
    this.status = BlocStatus.initial,
    this.history = const [],
    this.errorMessage,
    this.isOffline = false,
  });

  final BlocStatus status;
  final List<CurrencyHistoryPoint> history; // oldest -> newest
  final String? errorMessage;
  final bool isOffline;

  double? get low => history.isEmpty ? null : history.map((p) => p.rate).reduce(min);

  double? get high => history.isEmpty ? null : history.map((p) => p.rate).reduce(max);

  double? get range => (low == null || high == null) ? null : high! - low!;

  RateTrend get weekTrend {
    if (history.length < 2) return RateTrend.unchanged;
    final delta = history.last.rate - history.first.rate;
    if (delta < 0) return RateTrend.strengthening;
    if (delta > 0) return RateTrend.weakening;
    return RateTrend.unchanged;
  }

  CurrencyDetailStates copyWith({
    BlocStatus? status,
    List<CurrencyHistoryPoint>? history,
    String? errorMessage,
    bool? isOffline,
  }) {
    return CurrencyDetailStates(
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [status, history, errorMessage, isOffline];
}
