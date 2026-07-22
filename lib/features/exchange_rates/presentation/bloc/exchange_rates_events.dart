import 'package:equatable/equatable.dart';

sealed class ExchangeRateEvents extends Equatable {
  const ExchangeRateEvents();

  @override
  List<Object?> get props => [];
}

class GetExchangeRatesEvent extends ExchangeRateEvents {
  const GetExchangeRatesEvent();
}

class ConnectivityChangedEvent extends ExchangeRateEvents {
  const ConnectivityChangedEvent(this.isOnline);

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}


