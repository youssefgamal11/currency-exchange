import 'dart:convert';

import 'package:axis/core%20/storage/hive_storage.dart';
import 'package:axis/core%20/utils/common_functions.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/exchange_rates_response_entity.dart';
import '../models/exchange_rates_response_model.dart';

class CachedExchangeRates {
  const CachedExchangeRates({required this.data, required this.cachedAt});

  final ExchangeRateResponseEntity data;
  final DateTime cachedAt;
}

abstract class ExchangeRateLocalDataSource {
  Future<void> cacheExchangeRates(
    DateTime? dateTime,
    ExchangeRateResponseModel model,
  );

  CachedExchangeRates? getCachedExchangeRates(DateTime? dateTime);
}

@Injectable(as: ExchangeRateLocalDataSource)
class ExchangeRateLocalDataSourceImpl extends ExchangeRateLocalDataSource {
  Box get _box => HiveStorage.box(HiveStorage.exchangeRatesCacheBox());

  String _keyFor(DateTime? dateTime) =>
      dateTime == null ? 'latest' : CommonFunctions.formatDate(dateTime);

  @override
  Future<void> cacheExchangeRates(
    DateTime? dateTime,
    ExchangeRateResponseModel model,
  ) async {
    final envelope = jsonEncode({
      'data': model.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
    await _box.put(_keyFor(dateTime), envelope);
  }

  @override
  CachedExchangeRates? getCachedExchangeRates(DateTime? dateTime) {
    final raw = _box.get(_keyFor(dateTime));
    if (raw is! String) return null;

    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final data = ExchangeRateResponseModel.fromJson(
        Map<String, dynamic>.from(envelope['data']),
      );
      final cachedAt = DateTime.parse(envelope['cachedAt'] as String);
      return CachedExchangeRates(data: data, cachedAt: cachedAt);
    } catch (_) {
      return null;
    }
  }
}
