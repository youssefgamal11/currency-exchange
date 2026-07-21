import 'package:equatable/equatable.dart';

sealed class ExchangeRateEvents extends Equatable {
  const ExchangeRateEvents();

  @override
  List<Object?> get props => [];
}

class GetExchangeRateEvent extends ExchangeRateEvents {
  const GetExchangeRateEvent();
}


