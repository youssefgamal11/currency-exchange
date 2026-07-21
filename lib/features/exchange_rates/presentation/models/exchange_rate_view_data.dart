import 'package:flutter/material.dart';

import 'package:axis/core%20/theme/colors.dart';
import 'package:axis/core%20/utils/img_paths.dart';

import '../../domain/entity/exchange_rate_response_entity.dart';

class _SupportedCurrency {
  const _SupportedCurrency(this.code, this.name, this.flagAsset);

  final String code;
  final String name;
  final String flagAsset;
}

const _supportedCurrencies = [
  _SupportedCurrency('USD', 'US Dollar', ImgPath.flagUsd),
  _SupportedCurrency('EUR', 'Euro', ImgPath.flagEur),
  _SupportedCurrency('GBP', 'British Pound', ImgPath.flagGbp),
  _SupportedCurrency('SAR', 'Saudi Riyal', ImgPath.flagSar),
  _SupportedCurrency('JPY', 'Japanese Yen', ImgPath.flagJpy),
];

class ExchangeRateViewData {
  const ExchangeRateViewData({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.rate,
    required this.changeLabel,
    required this.color,
    required this.arrow,
  });

  final String code;
  final String name;
  final String flagAsset;
  final String rate;
  final String changeLabel;
  final Color color;
  final IconData? arrow;

  static double? _rateFor(EgpRatesEntity? egp, String code) {
    switch (code) {
      case 'USD':
        return egp?.usd;
      case 'EUR':
        return egp?.eur;
      case 'GBP':
        return egp?.gbp;
      case 'SAR':
        return egp?.sar;
      case 'JPY':
        return egp?.jpy;
    }
    return null;
  }

  /// Combines "latest" and "yesterday" raw API responses (EGP→foreign, uninverted)
  /// into display-ready rows, one per supported currency, with the daily change.
  static List<ExchangeRateViewData> build({
    required ExchangeRateResponseEntity latest,
    required ExchangeRateResponseEntity previous,
  }) {
    return _supportedCurrencies
        .where((currency) {
          final rawRate = _rateFor(latest.egp, currency.code);
          return rawRate != null && rawRate != 0;
        })
        .map((currency) {
          final todayRaw = _rateFor(latest.egp, currency.code)!;
          final yesterdayRaw = _rateFor(previous.egp, currency.code);

          final todayRate = 1 / todayRaw;
          final yesterdayRate = (yesterdayRaw == null || yesterdayRaw == 0)
              ? todayRate
              : 1 / yesterdayRaw;
          final changeAbsolute = todayRate - yesterdayRate;
          final changePercent = yesterdayRate == 0 ? 0.0 : (changeAbsolute / yesterdayRate) * 100;

          final isStrengthening = changeAbsolute < 0;
          final isWeakening = changeAbsolute > 0;
          final color = isStrengthening
              ? AppColors.good
              : isWeakening
                  ? AppColors.critical
                  : AppColors.textTertiary;
          final arrow = isStrengthening
              ? Icons.arrow_downward_rounded
              : isWeakening
                  ? Icons.arrow_upward_rounded
                  : null;
          final sign = changeAbsolute > 0 ? '+' : '';

          return ExchangeRateViewData(
            code: currency.code,
            name: currency.name,
            flagAsset: currency.flagAsset,
            rate: todayRate.toStringAsFixed(2),
            changeLabel: '$sign${changeAbsolute.toStringAsFixed(2)} EGP '
                '($sign${changePercent.toStringAsFixed(2)}%)',
            color: color,
            arrow: arrow,
          );
        })
        .toList();
  }
}
