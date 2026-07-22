import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:axis/features/currency_detail/presentation/bloc/currency_detail_states.dart';
import 'package:axis/features/currency_detail/presentation/widgets/current_rate_card.dart';
import 'package:axis/features/currency_detail/presentation/widgets/detail_offline_indicator.dart';
import 'package:axis/features/currency_detail/presentation/widgets/stat_card.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/widget_harness.dart';

void main() {
  group('CurrentRateCard', () {
    testWidgets('renders "1 CODE = rate EGP" with two decimals',
        (tester) async {
      await pumpWithHarness(
        tester,
        const CurrentRateCard(code: 'USD', rate: 48.5),
      );

      expect(find.text('Current Rate'), findsOneWidget);
      expect(
        find.textContaining('USD = '),
        findsOneWidget,
      );
      expect(find.textContaining('48.50'), findsOneWidget);
    });
  });

  group('StatCard', () {
    testWidgets('renders label, value and optional icon', (tester) async {
      await pumpWithHarness(
        tester,
        const StatCard(
          label: 'High',
          value: '0.021',
          icon: Icons.arrow_upward,
          valueColor: AppColors.good,
        ),
      );

      expect(find.text('High'), findsOneWidget);
      expect(find.text('0.021'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('omits the icon when none is provided', (tester) async {
      await pumpWithHarness(
        tester,
        const StatCard(label: 'Range', value: '0.001'),
      );

      expect(find.text('Range'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('DetailOfflineIndicator', () {
    late MockCurrencyDetailBloc bloc;

    setUp(() => bloc = MockCurrencyDetailBloc());
    tearDown(() => bloc.close());

    Future<void> pumpIndicator(
      WidgetTester tester,
      CurrencyDetailStates state,
    ) {
      whenListen(bloc, const Stream<CurrencyDetailStates>.empty(),
          initialState: state);
      return pumpWithHarness(
        tester,
        BlocProvider<CurrencyDetailBloc>.value(
          value: bloc,
          child: const DetailOfflineIndicator(),
        ),
      );
    }

    testWidgets('is hidden when online', (tester) async {
      await pumpIndicator(tester, const CurrencyDetailStates());

      expect(find.text('Offline .'), findsNothing);
    });

    testWidgets('shows the offline label when offline', (tester) async {
      await pumpIndicator(
        tester,
        const CurrencyDetailStates(isOffline: true),
      );

      expect(find.text('Offline .'), findsOneWidget);
    });
  });
}
