import 'package:flutter/material.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/utils/img_paths.dart';

import '../../domain/entity/currency_rate_change.dart';

class _CurrencyMeta {
  const _CurrencyMeta(this.name, this.flagAsset);

  final String name;
  final String flagAsset;
}

const _currencyMeta = {
  'USD': _CurrencyMeta('US Dollar', ImgPath.flagUsd),
  'EUR': _CurrencyMeta('Euro', ImgPath.flagEur),
  'GBP': _CurrencyMeta('British Pound', ImgPath.flagGbp),
  'SAR': _CurrencyMeta('Saudi Riyal', ImgPath.flagSar),
  'JPY': _CurrencyMeta('Japanese Yen', ImgPath.flagJpy),
};


class ExchangeRateViewData {
  const ExchangeRateViewData({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.rate,
    required this.changeAbsolute,
    required this.changePercent,
    required this.trend,
    required this.color,
  });

  final String code;
  final String name;
  final String flagAsset;
  final double rate;
  final double changeAbsolute;
  final double changePercent;
  final RateTrend trend;
  final Color color;

  String get rateLabel => rate.toStringAsFixed(2);

  String get changeLabel => '${changeAbsolute.abs().toStringAsFixed(2)} EGP '
      '(${changePercent.abs().toStringAsFixed(2)}%)';

  IconData? get trendIcon => switch (trend) {
    RateTrend.strengthening => Icons.arrow_upward,
    RateTrend.weakening => Icons.arrow_downward,
    RateTrend.unchanged => null,
  };

  factory ExchangeRateViewData.fromChange(CurrencyRateChange change) {
    final meta = _currencyMeta[change.code]!;
    final color = switch (change.trend) {
      RateTrend.strengthening => AppColors.good,
      RateTrend.weakening => AppColors.critical,
      RateTrend.unchanged => AppColors.textTertiary,
    };

    return ExchangeRateViewData(
      code: change.code,
      name: meta.name,
      flagAsset: meta.flagAsset,
      rate: change.rate,
      changeAbsolute: change.changeAbsolute,
      changePercent: change.changePercent,
      trend: change.trend,
      color: color,
    );
  }
}
