import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_header.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_empty.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_error.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_harness.dart';

void main() {
  group('ExchangeRateHeader', () {
    testWidgets('renders the title and refresh icon', (tester) async {
      await pumpWithHarness(tester, const ExchangeRateHeader());

      expect(find.text('Exchange Rates'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('invokes onRefresh when tapped', (tester) async {
      var tapped = 0;
      await pumpWithHarness(
        tester,
        ExchangeRateHeader(onRefresh: () => tapped++),
      );

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();

      expect(tapped, 1);
    });
  });

  group('ExchangeRateListError', () {
    testWidgets('shows the message and a Retry button', (tester) async {
      await pumpWithHarness(
        tester,
        ExchangeRateListError(message: 'No internet', onRetry: () {}),
      );

      expect(find.text('No internet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('invokes onRetry when the button is tapped', (tester) async {
      var retried = 0;
      await pumpWithHarness(
        tester,
        ExchangeRateListError(message: 'oops', onRetry: () => retried++),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, 1);
    });
  });

  group('ExchangeRateListEmpty', () {
    testWidgets('renders the empty message', (tester) async {
      await pumpWithHarness(tester, const ExchangeRateListEmpty());

      expect(find.text('No exchange rates available'), findsOneWidget);
    });
  });

  group('ExchangeRateListLoading', () {
    testWidgets('renders the requested number of shimmer rows', (tester) async {
      await pumpWithHarness(
        tester,
        const ExchangeRateListLoading(itemCount: 3),
      );

      expect(find.byType(ShimmarContainer), findsWidgets);
    });
  });
}
