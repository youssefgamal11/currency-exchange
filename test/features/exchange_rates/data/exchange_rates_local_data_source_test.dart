import 'package:axis/core%20/storage/hive_storage.dart';
import 'package:axis/features/exchange_rates/data/data_source/exchange_rates_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/hive_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempHive = TempHive();
  late Box box;
  late ExchangeRateLocalDataSourceImpl dataSource;

  setUp(() async {
    box = await tempHive.open(HiveStorage.exchangeRatesCacheBox());
    dataSource = ExchangeRateLocalDataSourceImpl();
  });

  tearDown(() => tempHive.close());

  test('round-trips cached data and cachedAt', () async {
    final model = buildResponse(usd: 48.5);

    await dataSource.cacheExchangeRates(null, model);
    final cached = dataSource.getCachedExchangeRates(null);

    expect(cached, isNotNull);
    expect(cached!.data.egp!.usd, 48.5);
    expect(cached.data.date, '2026-07-22');
    expect(cached.cachedAt, isNotNull);
  });

  test('unknown key returns null', () {
    expect(dataSource.getCachedExchangeRates(DateTime(2020, 1, 1)), isNull);
  });

  test('corrupt (non-string) stored value returns null', () async {
    await box.put('latest', 12345);
    expect(dataSource.getCachedExchangeRates(null), isNull);
  });

  test('null date is keyed as "latest", a date as formatted string', () async {
    await dataSource.cacheExchangeRates(null, buildResponse(usd: 1));
    await dataSource.cacheExchangeRates(
      DateTime(2026, 7, 21),
      buildResponse(usd: 2),
    );

    expect(box.containsKey('latest'), isTrue);
    expect(box.containsKey('2026-07-21'), isTrue);
    expect(dataSource.getCachedExchangeRates(null)!.data.egp!.usd, 1);
    expect(
      dataSource.getCachedExchangeRates(DateTime(2026, 7, 21))!.data.egp!.usd,
      2,
    );
  });
}
