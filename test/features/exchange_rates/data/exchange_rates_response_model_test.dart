import 'package:axis/features/exchange_rates/data/models/exchange_rates_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeRateResponseModel', () {
    test('fromJson -> toJson round-trips date and all rates', () {
      final json = {
        'date': '2026-07-22',
        'egp': {
          'usd': 48.0,
          'eur': 52.0,
          'gbp': 61.0,
          'sar': 12.8,
          'jpy': 0.33,
        },
      };

      final model = ExchangeRateResponseModel.fromJson(json);
      final out = model.toJson();

      expect(out['date'], '2026-07-22');
      expect(out['egp'], {
        'usd': 48.0,
        'eur': 52.0,
        'gbp': 61.0,
        'sar': 12.8,
        'jpy': 0.33,
      });
    });

    test('missing egp yields null', () {
      final model = ExchangeRateResponseModel.fromJson({'date': '2026-07-22'});

      expect(model.egp, isNull);
      expect(model.toJson()['egp'], isNull);
    });

    test('missing date defaults to empty string', () {
      final model = ExchangeRateResponseModel.fromJson({'egp': {}});
      expect(model.date, '');
    });

    test('missing individual rate fields default to 0.0', () {
      final model = ExchangeRateResponseModel.fromJson({
        'date': '2026-07-22',
        'egp': {'usd': 48.0},
      });

      expect(model.egp!.usd, 48.0);
      expect(model.egp!.eur, 0.0);
      expect(model.egp!.jpy, 0.0);
    });
  });

  group('EgpRatesEntity operator[]', () {
    test('maps supported codes and returns null for unknown', () {
      final model = ExchangeRateResponseModel.fromJson({
        'date': '2026-07-22',
        'egp': {
          'usd': 48.0,
          'eur': 52.0,
          'gbp': 61.0,
          'sar': 12.8,
          'jpy': 0.33,
        },
      });
      final egp = model.egp!;

      expect(egp['USD'], 48.0);
      expect(egp['EUR'], 52.0);
      expect(egp['GBP'], 61.0);
      expect(egp['SAR'], 12.8);
      expect(egp['JPY'], 0.33);
      expect(egp['CAD'], isNull);
    });
  });
}
