import 'package:equatable/equatable.dart';

sealed class CurrencyDetailEvents extends Equatable {
  const CurrencyDetailEvents();

  @override
  List<Object?> get props => [];
}

class GetCurrencyHistoryEvent extends CurrencyDetailEvents {
  const GetCurrencyHistoryEvent({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}
