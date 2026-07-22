import 'dart:convert';

import 'package:axis/core%20/storage/hive_storage.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/currency_history_point.dart';

abstract class CurrencyHistoryLocalDataSource {
  Future<void> cacheHistory(String code, List<CurrencyHistoryPoint> history);

  List<CurrencyHistoryPoint>? getCachedHistory(String code);
}

@Injectable(as: CurrencyHistoryLocalDataSource)
class CurrencyHistoryLocalDataSourceImpl extends CurrencyHistoryLocalDataSource {
  Box get _box => HiveStorage.box(HiveStorage.currencyHistoryBox());

  @override
  Future<void> cacheHistory(
    String code,
    List<CurrencyHistoryPoint> history,
  ) async {
    final encoded = jsonEncode([
      for (final point in history)
        {'date': point.date.toIso8601String(), 'rate': point.rate},
    ]);
    await _box.put(code, encoded);
  }

  @override
  List<CurrencyHistoryPoint>? getCachedHistory(String code) {
    final raw = _box.get(code);
    if (raw is! String) return null;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          CurrencyHistoryPoint(
            date: DateTime.parse(item['date'] as String),
            rate: (item['rate'] as num).toDouble(),
          ),
      ];
    } catch (_) {
      return null;
    }
  }
}
