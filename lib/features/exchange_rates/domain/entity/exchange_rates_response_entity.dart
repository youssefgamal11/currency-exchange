class ExchangeRateResponseEntity {
  String? date;
  EgpRatesEntity? egp;

  ExchangeRateResponseEntity({this.date, this.egp});
}

class EgpRatesEntity {
  double? usd;
  double? eur;
  double? gbp;
  double? sar;
  double? jpy;

  EgpRatesEntity({this.usd, this.eur, this.gbp, this.sar, this.jpy});
}
