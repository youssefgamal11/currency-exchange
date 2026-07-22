import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/features/currency_detail/domain/entity/currency_history_point.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_states.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';
import 'package:flutter_test/flutter_test.dart';

CurrencyHistoryPoint _point(double rate, [int day = 1]) =>
    CurrencyHistoryPoint(date: DateTime(2026, 7, day), rate: rate);

void main() {
  group('CurrencyDetailStates computed getters', () {
    test('empty history returns nulls and unchanged trend', () {
      const state = CurrencyDetailStates();

      expect(state.low, isNull);
      expect(state.high, isNull);
      expect(state.range, isNull);
      expect(state.weekTrend, RateTrend.unchanged);
    });

    test('single point: low == high, range 0, trend unchanged', () {
      final state = CurrencyDetailStates(history: [_point(0.02)]);

      expect(state.low, 0.02);
      expect(state.high, 0.02);
      expect(state.range, 0);
      expect(state.weekTrend, RateTrend.unchanged);
    });

    test('range is high - low across multiple points', () {
      final state = CurrencyDetailStates(
        history: [_point(0.02, 1), _point(0.03, 2), _point(0.025, 3)],
      );

      expect(state.low, 0.02);
      expect(state.high, 0.03);
      expect(state.range, closeTo(0.01, 1e-12));
    });

    test('rising rate over the week => weakening', () {
      final state = CurrencyDetailStates(
        history: [_point(0.02, 1), _point(0.025, 7)],
      );

      expect(state.weekTrend, RateTrend.weakening);
    });

    test('falling rate over the week => strengthening', () {
      final state = CurrencyDetailStates(
        history: [_point(0.025, 1), _point(0.02, 7)],
      );

      expect(state.weekTrend, RateTrend.strengthening);
    });
  });

  group('CurrencyDetailStates copyWith', () {
    test('preserves unspecified fields', () {
      final original = CurrencyDetailStates(
        status: BlocStatus.success,
        history: [_point(0.02)],
        isOffline: true,
      );

      final copy = original.copyWith(status: BlocStatus.loading);

      expect(copy.status, BlocStatus.loading);
      expect(copy.history, original.history);
      expect(copy.isOffline, isTrue);
    });
  });
}
