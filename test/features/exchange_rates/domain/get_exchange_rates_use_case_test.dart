import 'package:axis/features/exchange_rates/domain/use_cases/get_exchange_rates_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockExchangeRateRepository repository;
  late GetExchangeRatesUseCase useCase;

  setUp(() {
    repository = MockExchangeRateRepository();
    useCase = GetExchangeRatesUseCase(exchangeRateRepository: repository);
  });

  test('returns the repository result unchanged', () async {
    final result = buildResult();
    when(() => repository.getExchangeRates(any()))
        .thenAnswer((_) async => Right(result));

    final either = await useCase(null);

    expect(either, Right<String, dynamic>(result));
  });

  test('forwards the date argument to the repository', () async {
    final date = DateTime(2026, 7, 21);
    when(() => repository.getExchangeRates(any()))
        .thenAnswer((_) async => Right(buildResult()));

    await useCase(date);

    verify(() => repository.getExchangeRates(date)).called(1);
  });

  test('propagates a Left failure', () async {
    when(() => repository.getExchangeRates(any()))
        .thenAnswer((_) async => const Left('boom'));

    final either = await useCase(null);

    expect(either, const Left<String, dynamic>('boom'));
  });
}
