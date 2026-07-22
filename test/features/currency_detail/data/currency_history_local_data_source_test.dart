import 'package:axis/core%20/storage/hive_storage.dart';
import 'package:axis/features/currency_detail/data/data_source/currency_history_local_data_source.dart';
import 'package:axis/features/currency_detail/domain/entity/currency_history_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../helpers/hive_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tempHive = TempHive();
  late Box box;
  late CurrencyHistoryLocalDataSourceImpl dataSource;

  setUp(() async {
    box = await tempHive.open(HiveStorage.currencyHistoryBox());
    dataSource = CurrencyHistoryLocalDataSourceImpl();
  });

  tearDown(() => tempHive.close());

  test('round-trips history points for a code', () async {
    final history = [
      CurrencyHistoryPoint(date: DateTime(2026, 7, 20), rate: 0.02),
      CurrencyHistoryPoint(date: DateTime(2026, 7, 21), rate: 0.021),
    ];

    await dataSource.cacheHistory('USD', history);
    final cached = dataSource.getCachedHistory('USD');

    expect(cached, isNotNull);
    expect(cached!.length, 2);
    expect(cached[0].rate, 0.02);
    expect(cached[0].date, DateTime(2026, 7, 20));
    expect(cached[1].rate, 0.021);
  });

  test('unknown code returns null', () {
    expect(dataSource.getCachedHistory('EUR'), isNull);
  });

  test('corrupt JSON returns null', () async {
    await box.put('USD', 'not-json');
    expect(dataSource.getCachedHistory('USD'), isNull);
  });
}
