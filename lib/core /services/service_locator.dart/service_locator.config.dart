// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../../features/exchange_rates/data/data_source/exchange_rates_remote_data_source.dart'
    as _i824;
import '../../../features/exchange_rates/data/repository_impl/exchange_rates_repository_impl.dart'
    as _i49;
import '../../../features/exchange_rates/domain/repository/exchange_rates_repository.dart'
    as _i388;
import '../../../features/exchange_rates/domain/use_cases/get_exchange_rates_use_case.dart'
    as _i576;
import '../../../features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart'
    as _i1049;
import '../network/dio_impl.dart' as _i856;
import '../network/network_helper.dart' as _i369;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i369.NetworkHelper>(() => _i856.DioImpl());
    gh.factory<_i824.ExchangeRateRemoteDataSource>(
      () => _i824.ExchangeRateRemoteDataSourceImpl(
        networkHelper: gh<_i369.NetworkHelper>(),
      ),
    );
    gh.factory<_i388.ExchangeRateRepository>(
      () => _i49.ExchangeRateRepositoryImpl(
        exchangeRateRemoteDataSource: gh<_i824.ExchangeRateRemoteDataSource>(),
      ),
    );
    gh.factory<_i576.GetExchangeRatesUseCase>(
      () => _i576.GetExchangeRatesUseCase(
        exchangeRateRepository: gh<_i388.ExchangeRateRepository>(),
      ),
    );
    gh.factory<_i1049.ExchangeRateBloc>(
      () => _i1049.ExchangeRateBloc(gh<_i576.GetExchangeRatesUseCase>()),
    );
    return this;
  }
}
