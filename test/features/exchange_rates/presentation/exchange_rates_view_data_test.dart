import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/utils/img_paths.dart';
import 'package:axis/features/exchange_rates/domain/entity/currency_rate_change.dart';
import 'package:axis/features/exchange_rates/presentation/models/exchange_rates_view_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CurrencyRateChange _change({
  String code = 'USD',
  double rate = 0.02,
  double changeAbsolute = 0.001,
  double changePercent = 5,
  RateTrend trend = RateTrend.strengthening,
}) {
  return CurrencyRateChange(
    code: code,
    rate: rate,
    changeAbsolute: changeAbsolute,
    changePercent: changePercent,
    trend: trend,
  );
}

void main() {
  group('ExchangeRateViewData.fromChange', () {
    test('maps name and flag asset from currency metadata', () {
      final data = ExchangeRateViewData.fromChange(_change(code: 'USD'));

      expect(data.name, 'US Dollar');
      expect(data.flagAsset, ImgPath.flagUsd);
    });

    test('color reflects the trend', () {
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.strengthening),
        ).color,
        AppColors.good,
      );
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.weakening),
        ).color,
        AppColors.critical,
      );
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.unchanged),
        ).color,
        AppColors.textTertiary,
      );
    });

    test('rateLabel formats to two decimals', () {
      final data = ExchangeRateViewData.fromChange(_change(rate: 48.2));
      expect(data.rateLabel, '48.20');
    });

    test('changeLabel uses absolute values in "X EGP (Y%)" form', () {
      final data = ExchangeRateViewData.fromChange(
        _change(changeAbsolute: -1.234, changePercent: -2.5),
      );
      expect(data.changeLabel, '1.23 EGP (2.50%)');
    });

    test('trendIcon reflects the trend', () {
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.strengthening),
        ).trendIcon,
        Icons.arrow_upward,
      );
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.weakening),
        ).trendIcon,
        Icons.arrow_downward,
      );
      expect(
        ExchangeRateViewData.fromChange(
          _change(trend: RateTrend.unchanged),
        ).trendIcon,
        isNull,
      );
    });
  });
}
