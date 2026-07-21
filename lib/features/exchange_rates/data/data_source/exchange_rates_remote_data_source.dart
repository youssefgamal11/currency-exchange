import 'package:axis/core%20/services/network/network_helper.dart';
import 'package:axis/core%20/utils/common_functions.dart';
import 'package:axis/core%20/utils/end_points.dart';
import 'package:injectable/injectable.dart';

import '../models/exchange_rates_response_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<ExchangeRateResponseModel> getExchangeRates(DateTime? dateTime);
}

@Injectable(as: ExchangeRateRemoteDataSource)
class ExchangeRateRemoteDataSourceImpl extends ExchangeRateRemoteDataSource {
  final NetworkHelper networkHelper;
  ExchangeRateRemoteDataSourceImpl({required this.networkHelper});

  @override
  Future<ExchangeRateResponseModel> getExchangeRates(DateTime? dateTime) async {
    final response = await networkHelper.get(
      path: dateTime != null
          ? ApiUrls.currencyApiHistoricalEgp(CommonFunctions.formatDate(dateTime))
          : ApiUrls.currencyApiLatestEgp,
      isFullPath: true,
    );

    return ExchangeRateResponseModel.fromJson(response);
  }
}
