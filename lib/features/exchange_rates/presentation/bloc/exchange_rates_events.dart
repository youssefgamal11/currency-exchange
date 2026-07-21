import 'package:equatable/equatable.dart';

sealed class ExchangeRateEvents extends Equatable {
  const ExchangeRateEvents();

  @override
  List<Object?> get props => [];
}

class GetExchangeRatesEvent extends ExchangeRateEvents {
  const GetExchangeRatesEvent();
}


