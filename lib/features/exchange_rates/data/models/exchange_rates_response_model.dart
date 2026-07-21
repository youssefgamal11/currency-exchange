import '../../domain/entity/exchange_rate_response_entity.dart';

class ExchangeRateResponseModel extends ExchangeRateResponseEntity {
  ExchangeRateResponseModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? "";
    egp = json['egp'] != null ? EgpRatesModel.fromJson(json['egp']) : null;
  }
}

class EgpRatesModel extends EgpRatesEntity {
  EgpRatesModel.fromJson(Map<String, dynamic> json) {
    usd = json['usd'] ?? 0.0;
    eur = json['eur'] ?? 0.0;
    gbp = json['gbp'] ?? 0.0;
    sar = json['sar'] ?? 0.0;
    jpy = json['jpy'] ?? 0.0;
  }
}
