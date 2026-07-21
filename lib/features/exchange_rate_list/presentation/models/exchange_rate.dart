class ExchangeRate {
  const ExchangeRate({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.rate,
    required this.changeLabel,
    required this.isPositive,
    required this.sparklinePoints,
  });

  final String code;
  final String name;
  final String flagAsset;
  final String rate;
  final String changeLabel;
  final bool isPositive;
  final List<double> sparklinePoints;
}
