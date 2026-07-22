# Currency Detail Screen — Module 2: Historical Chart

## Context

The Exchange Rate List screen (`lib/features/exchange_rates/`) is done and API-wired. This
doc covers **Module 2: Currency Detail** — a screen reached by tapping a currency row in
that list, showing the current rate, daily change, and a 7-day history chart for that pair.

Unlike Module 1, this feature has **no `data/` layer of its own**. The top section (current
rate, daily change absolute/percent, yesterday's rate, last-update date) is already known by
the time the user taps a row — it's passed forward as navigation arguments, not re-fetched.
Only the 7-day chart needs new data, fetched by calling the **existing**
`GetExchangeRatesUseCase` 7 times (once per day) — no new repository, no new data source, no
new use case wrapper. This is a deliberate cross-feature reuse.

## Color/semantics callout (same rule as the list screen — do not deviate)

`changeAbsolute > 0` (rate increase) → EGP **weakened** → **red** (`AppColors.critical`).
`changeAbsolute < 0` (rate decrease) → EGP **strengthened** → **green** (`AppColors.good`).
`== 0` → neutral gray (`AppColors.textTertiary`). This is the same inverted-from-a-naive-
stock-ticker convention documented in `exchange_rate_list.md` and implemented in
`currency_rate_change.dart` — the reference screenshot for this screen shows the opposite
(green for an increase), which is treated as a mockup color bug and corrected here, the same
way an earlier Figma Make coloring bug was corrected for the list screen (AI_USAGE.md
Entry 1). The reference screenshot's chart y-axis labels are also visibly broken (repeating
values) — the real chart computes `minY`/`maxY` from the actual fetched 7-day range instead
of any literal axis values from the mockup.

## Architecture / folder structure

```
lib/features/currency_detail/
  domain/
    entity/
      currency_history_point.dart        # {date, rate} — rate already inverted EGP-per-unit
  presentation/
    bloc/
      currency_detail_bloc.dart
      currency_detail_events.dart
      currency_detail_states.dart
    models/
      currency_detail_args.dart          # navigation-argument snapshot from the list screen
    pages/
      currency_detail_page.dart
    widgets/
      currency_detail_header.dart        # back button + flag/code/name identity row
      current_rate_card.dart             # big amber current-rate card
      stat_card.dart                     # reusable data-driven tile
      stat_card_grid.dart                # feeds stat_card 4x from args
      currency_history_chart_card.dart   # owns the BlocBuilder + loading/error/success branching
      currency_history_chart.dart        # fl_chart LineChart
      currency_history_chart_loading.dart# shimmer skeleton (not a spinner)
      currency_history_chart_error.dart  # message + retry
      currency_history_stats_row.dart    # 7D Low / High / Range
      inverted_rate_info_banner.dart     # "rate is inverted from the API" banner
```

No `domain/repository` or `domain/use_cases` — the bloc calls `GetExchangeRatesUseCase`
directly, mirroring how `ExchangeRateBloc.getExchangeRateList` already combines its own two
calls itself rather than through a wrapper use case (the as-built precedent in this
codebase, not what the original `exchange_rate_list.md` had planned).

### Reused data contract

`GetExchangeRatesUseCase.call(DateTime? dateTime)` → `Either<String, ExchangeRateResponseEntity>`
(`null` = latest, a `DateTime` = historical for that day, formatted `YYYY-MM-DD` internally).
`ExchangeRateResponseEntity.egp` is an `EgpRatesEntity` with `operator [](String code)`
giving the raw EGP→foreign quote — invert (`1 / raw`) for EGP-per-unit, same as
`CurrencyRateChange.fromQuotes`.

### `domain/entity/currency_history_point.dart`

```dart
class CurrencyHistoryPoint {
  const CurrencyHistoryPoint({required this.date, required this.rate});
  final DateTime date;
  final double rate; // EGP per 1 foreign unit, already inverted
}
```

### One small edit to `exchange_rates`' presentation layer

`ExchangeRateViewData` (`lib/features/exchange_rates/presentation/models/exchange_rates_view_data.dart`)
previously only stored formatted display strings, losing the raw precision this screen needs
(4-decimal daily change vs. the list's 2-decimal string). It now also carries the raw
`changeAbsolute`, `changePercent`, and `trend` (already computed in `fromChange()`, just not
previously kept), exposing `rateLabel`/`changeLabel` as getters instead of stored strings.
`ExchangeRateListItem` (the only other consumer) uses those getters instead of the old
fields.

### Navigation

`ExchangeRateListItem` gained an `onTap` (wrapping its existing `Container` in an `InkWell`,
same border radius) that reads `lastUpdated` from `context.read<ExchangeRateBloc>().state`
at tap time (always available — the item only renders inside the router's
`BlocProvider<ExchangeRateBloc>`) and pushes `RouteName.currencyDetail` with a
`CurrencyDetailArgs.fromViewData(item, lastUpdated)` argument.

`CurrencyDetailArgs` (code, name, flagAsset, rate, changeAbsolute, changePercent, trend,
lastUpdated) is the plain snapshot passed forward. `yesterdayRate` is a derived getter
(`rate - changeAbsolute`), not a stored field, to avoid a second source of truth.

### `presentation/`

- `bloc/currency_detail_events.dart` — a single `GetCurrencyHistoryEvent({required String
  code})`. The event carries only the code — that's the one thing the top-of-screen args
  can't substitute for, since each of the 7 API responses returns all currencies and the
  bloc must pick this one out of each.
- `bloc/currency_detail_states.dart` — `CurrencyDetailStates` using the shared `BlocStatus`
  enum. Carries `List<CurrencyHistoryPoint> history` (oldest→newest) and `String?
  errorMessage`. `low`/`high`/`range`/`weekTrend` are **computed getters** off `history`, not
  stored fields — avoids a second source of truth. `weekTrend` (first-vs-last point of the
  7-day series, same sign rule as `CurrencyRateChange`) drives the chart line's color,
  deliberately *not* reusing `args.trend` (the header's single-day change), since the chart
  represents a 7-day span and could otherwise show a color that contradicts its own line's
  direction.
- `bloc/currency_detail_bloc.dart` — `CurrencyDetailBloc(GetExchangeRatesUseCase)`, one
  `on<GetCurrencyHistoryEvent>` handler:
  1. `Future.wait` over 6 historical calls (`now-6d` … `now-1d`) **plus one `null` (latest)
     call** for today — using `latest` rather than a historical call for "today" guarantees
     the chart's newest point matches the header's Current Rate exactly (both come from the
     same `latest` snapshot).
  2. Folds the 7 `Either<String, ExchangeRateResponseEntity>` results via a manual
     fold-into-two-lists loop (not chained `flatMap`, which doesn't scale past 2 items):
     first failure in call order short-circuits to `BlocStatus.failure`, matching the
     existing 2-call `ExchangeRateBloc` precedent.
  3. For each successful response, extracts `response.egp?[code]`; skips null/zero days
     (same rule as `CurrencyRateChange.fromResponses`) rather than zero-filling them.
  4. Emits `BlocStatus.success` with the resulting `List<CurrencyHistoryPoint>`.
  If fewer than 2 usable points remain, the chart card shows a "not enough history data"
  error state rather than drawing a degenerate chart.
- `pages/currency_detail_page.dart` — a plain `StatelessWidget(required this.args)`.
  Everything except the chart card renders straight from `args` on the first frame — no
  bloc dependency for the top section.
- `widgets/currency_detail_header.dart`, `current_rate_card.dart` — one-off widgets (back
  button/identity row, big rate card).
- `widgets/stat_card.dart` + `stat_card_grid.dart` — the reusable "one data-driven widget fed
  different data" pattern (same consolidation principle as the onboarding chip widgets,
  AI_USAGE.md Entry 5) for the 4 grid cells: daily change, change %, yesterday, last update.
- `widgets/currency_history_chart_card.dart` — owns its own
  `BlocBuilder<CurrencyDetailBloc, CurrencyDetailStates>`, branching on `status`: failure →
  `currency_history_chart_error.dart` (message + retry, re-dispatching
  `GetCurrencyHistoryEvent`); not yet success → `currency_history_chart_loading.dart`
  (`Shimmer.fromColors`, same pattern as `exchange_rates_list_loading.dart` — never a
  spinner); success with <2 points → the error widget with a "not enough history" message;
  otherwise → `currency_history_chart.dart` + `currency_history_stats_row.dart`.
- `widgets/currency_history_chart.dart` — `fl_chart`'s `LineChart`. `minY`/`maxY` computed
  from the actual fetched rates + small padding (the deliberate fix for the mockup's broken
  axis labels). Line colored by `state.weekTrend`. X-axis labels use a new
  `CommonFunctions.formatShortDate` helper (hand-rolled, no `intl`, matching this project's
  existing rule) instead of parsed API date strings.
- `widgets/currency_history_stats_row.dart` — "7D Low"/"7D High"/"7D Range",
  `.toStringAsFixed(4)`.
- `widgets/inverted_rate_info_banner.dart` — static banner using `AppColors.info`/`infoTint`.

## Routing owns the `BlocProvider`

Same pattern as `exchangeRateList`, plus argument extraction:
```dart
case RouteName.currencyDetail:
  final args = settings.arguments as CurrencyDetailArgs;
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<CurrencyDetailBloc>()..add(GetCurrencyHistoryEvent(code: args.code)),
      child: CurrencyDetailPage(args: args),
    ),
  );
```

## DI wiring

`service_locator.config.dart` is hand-maintained (no working build_runner/injectable
pipeline in this repo) — `CurrencyDetailBloc` is added manually, depending on the
already-registered `GetExchangeRatesUseCase`. No new repository/data-source registration.

## Small core additions

- `CommonFunctions.formatShortDate(DateTime)` in `core/utils/common_functions.dart` —
  hand-rolled `"Jul 14"`-style formatting for the chart's x-axis labels (no `intl`).
- `fl_chart: ^1.2.0` added fresh to `pubspec.yaml` — not previously a dependency in this
  repo, so its exact param names were verified against the installed version while
  implementing rather than assumed from memory.

## Explicitly out of scope

- Any change to `exchange_rates`' repository/data source/endpoints.
- Caching/persisting the 7-day history across navigations (refetches every visit).
- Landscape support (app is already portrait-locked).
- Wiring anything other than the list-item tap into this route.
