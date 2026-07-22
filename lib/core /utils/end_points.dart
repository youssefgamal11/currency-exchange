class ApiUrls {
  static const String currencyApiLatestEgp =
      "https://latest.currency-api.pages.dev/v1/currencies/egp.json";

  static String currencyApiHistoricalEgp(String formattedDate) =>
      "https://$formattedDate.currency-api.pages.dev/v1/currencies/egp.json";
}
