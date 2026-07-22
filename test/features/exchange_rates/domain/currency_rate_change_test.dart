import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CurrencyRateChange.fromQuotes', () {
    test('rate is the inverse of the raw quote', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 50,
        yesterdayQuote: 50,
      );

      expect(change.rate, closeTo(1 / 50, 1e-12));
    });

    test('null yesterday quote yields zero change and unchanged trend', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 50,
        yesterdayQuote: null,
      );

      expect(change.changeAbsolute, 0);
      expect(change.changePercent, 0);
      expect(change.trend, RateTrend.unchanged);
    });

    test('zero yesterday quote falls back to today (unchanged)', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 50,
        yesterdayQuote: 0,
      );

      expect(change.changeAbsolute, 0);
      expect(change.trend, RateTrend.unchanged);
    });

    test('rate up (quote down) => weakening', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 40,
        yesterdayQuote: 50,
      );

      expect(change.rate, greaterThan(1 / 50));
      expect(change.changeAbsolute, greaterThan(0));
      expect(change.trend, RateTrend.weakening);
    });

    test('rate down (quote up) => strengthening', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 50,
        yesterdayQuote: 40,
      );

      expect(change.changeAbsolute, lessThan(0));
      expect(change.trend, RateTrend.strengthening);
    });

    test('changePercent = changeAbsolute / previousRate * 100', () {
      final change = CurrencyRateChange.fromQuotes(
        code: 'USD',
        todayQuote: 40,
        yesterdayQuote: 50,
      );

      final previousRate = 1 / 50;
      final expected = (change.changeAbsolute / previousRate) * 100;
      expect(change.changePercent, closeTo(expected, 1e-9));
    });
  });

  group('CurrencyRateChange.fromResponses', () {
    test('produces one change per supported currency', () {
      final changes = CurrencyRateChange.fromResponses(
        latest: buildResponse(),
        previous: buildResponse(),
      );

      expect(
        changes.map((c) => c.code).toList(),
        kSupportedCurrencyCodes,
      );
    });

    test('skips currencies whose latest quote is zero', () {
      final changes = CurrencyRateChange.fromResponses(
        latest: buildResponse(usd: 0),
        previous: buildResponse(),
      );

      expect(changes.any((c) => c.code == 'USD'), isFalse);
      expect(changes.length, kSupportedCurrencyCodes.length - 1);
    });

    test('pairs each latest quote with the matching previous quote', () {
      final changes = CurrencyRateChange.fromResponses(
        latest: buildResponse(usd: 40),
        previous: buildResponse(usd: 50),
      );

      final usd = changes.firstWhere((c) => c.code == 'USD');
      expect(usd.trend, RateTrend.weakening);
    });
  });
}
