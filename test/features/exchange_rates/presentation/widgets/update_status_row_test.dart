import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_states.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/update_status_row.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/widget_harness.dart';

void main() {
  late MockExchangeRateBloc bloc;

  setUp(() => bloc = MockExchangeRateBloc());

  tearDown(() => bloc.close());

  Future<void> pumpRow(WidgetTester tester, ExchangeRateStates state) {
    whenListen(bloc, const Stream<ExchangeRateStates>.empty(),
        initialState: state);
    return pumpWithHarness(
      tester,
      BlocProvider<ExchangeRateBloc>.value(
        value: bloc,
        child: const UpdateStatusRow(),
      ),
    );
  }

  testWidgets('shows an em dash when there is no last-updated time',
      (tester) async {
    await pumpRow(tester, const ExchangeRateStates());

    expect(find.text('Updated —'), findsOneWidget);
  });

  testWidgets('shows the formatted time when online', (tester) async {
    await pumpRow(
      tester,
      ExchangeRateStates(lastUpdated: DateTime(2026, 7, 22, 15, 5)),
    );

    expect(find.text('Updated 3:05 PM'), findsOneWidget);
  });

  testWidgets('prefixes with "Offline ·" when offline', (tester) async {
    await pumpRow(
      tester,
      ExchangeRateStates(
        isOffline: true,
        lastUpdated: DateTime(2026, 7, 22, 15, 5),
      ),
    );

    expect(find.text('Offline · Updated 3:05 PM'), findsOneWidget);
  });
}
