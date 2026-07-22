import 'package:axis/core%20/enums/bloc_status.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_events.dart';
import 'package:axis/features/exchange_rates/presentation/bloc/exchange_rates_states.dart';
import 'package:axis/features/exchange_rates/presentation/models/exchange_rates_view_data.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_body.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_empty.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_error.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_item.dart';
import 'package:axis/features/exchange_rates/presentation/widgets/exchange_rates_list_loading.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/widget_harness.dart';

ExchangeRateViewData _viewData() => ExchangeRateViewData.fromChange(
      const CurrencyRateChange(
        code: 'USD',
        rate: 48.0,
        changeAbsolute: 0.5,
        changePercent: 1.0,
        trend: RateTrend.strengthening,
      ),
    );

void main() {
  late MockExchangeRateBloc bloc;

  setUp(() => bloc = MockExchangeRateBloc());

  tearDown(() => bloc.close());

  Future<void> pumpBody(WidgetTester tester, ExchangeRateStates state) {
    whenListen(bloc, const Stream<ExchangeRateStates>.empty(),
        initialState: state);
    return pumpWithHarness(
      tester,
      BlocProvider<ExchangeRateBloc>.value(
        value: bloc,
        child: const ExchangeRateListWidget(),
      ),
    );
  }

  testWidgets('loading status renders the shimmer loading list',
      (tester) async {
    await pumpBody(tester, const ExchangeRateStates(status: BlocStatus.loading));

    expect(find.byType(ExchangeRateListLoading), findsOneWidget);
  });

  testWidgets('failure status renders the error widget with the message',
      (tester) async {
    await pumpBody(
      tester,
      const ExchangeRateStates(
        status: BlocStatus.failure,
        errorMessage: 'No internet connection',
      ),
    );

    expect(find.byType(ExchangeRateListError), findsOneWidget);
    expect(find.text('No internet connection'), findsOneWidget);
  });

  testWidgets('success with an empty list renders the empty widget',
      (tester) async {
    await pumpBody(
      tester,
      const ExchangeRateStates(status: BlocStatus.success),
    );

    expect(find.byType(ExchangeRateListEmpty), findsOneWidget);
  });

  testWidgets('success with data renders one item per rate', (tester) async {
    await pumpBody(
      tester,
      ExchangeRateStates(
        status: BlocStatus.success,
        exchangeRateList: [_viewData()],
      ),
    );

    expect(find.byType(ExchangeRateListItem), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('tapping Retry dispatches GetExchangeRatesEvent', (tester) async {
    await pumpBody(
      tester,
      const ExchangeRateStates(
        status: BlocStatus.failure,
        errorMessage: 'boom',
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => bloc.add(const GetExchangeRatesEvent())).called(1);
  });
}
