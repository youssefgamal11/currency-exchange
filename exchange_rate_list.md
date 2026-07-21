# Exchange Rate List Screen — Module 1: API Integration

## Context

The UI-only phase is done (design-token-driven screen, hardcoded mock data, no Bloc, no
real navigation). This doc now covers **Module 1: Exchange Rates List** — wiring that
screen to the real currency-rates API and restructuring the feature into clean
architecture (`data` / `domain` / `presentation`), matching the layered structure used
elsewhere in the app.

Unlike the UI-only phase, this is a real `flutter_bloc` (Bloc, event-driven) feature: it
fetches live data, has loading/error/empty states, and supports pull-to-refresh.

**Ownership split**: the `data/` layer (data source, models, repository impl) is being
built separately, not by this pass — this doc documents the *contract* the domain layer
expects from it, not its file contents.

## API reference

Open-source currency-rates API. No key, no auth, no rate limits, JSON GET requests. Rates
update once a day.

| Purpose | URL pattern | Example |
|---|---|---|
| Latest rates | `latest.currency-api.pages.dev/v1/currencies/{base}.json` | `https://latest.currency-api.pages.dev/v1/currencies/egp.json` |
| Historical rates | `{YYYY-MM-DD}.currency-api.pages.dev/v1/currencies/{base}.json` | `https://2026-06-01.currency-api.pages.dev/v1/currencies/egp.json` |

How it works:
- One call returns **all** 200+ rates for the chosen base currency — base is always `egp`
  for this task, so every request hits `egp.json`.
- The response is keyed **EGP → foreign**, e.g. `egp.usd = 0.019227` means 1 EGP = 0.019227
  USD. To display "1 USD = X EGP", **invert** the value: `1 / 0.019227 = 52.01`.
- Daily change requires two calls: latest (`latest.currency-api...`) and yesterday
  (historical endpoint with yesterday's date) — then diff the inverted rates.

Currency pairs for this task (fixed set, not derived from the API):

| Currency | Code | Response key | Display format |
|---|---|---|---|
| US Dollar | USD | `egp.usd` | 1 USD = 52.01 EGP |
| Euro | EUR | `egp.eur` | 1 EUR = 60.52 EGP |
| British Pound | GBP | `egp.gbp` | 1 GBP = 70.02 EGP |
| Saudi Riyal | SAR | `egp.sar` | 1 SAR = 13.87 EGP |
| Japanese Yen | JPY | `egp.jpy` | 1 JPY = 0.33 EGP |

**Color/arrow semantics — important, easy to get backwards**: green = EGP *strengthening*,
red = EGP *weakening*. Since the displayed rate is EGP-per-unit-foreign-currency, EGP
strengthens when that rate **decreases** (foreign currency got cheaper in EGP terms) and
weakens when it **increases**. So:
- `changeAbsolute < 0` (today's rate lower than yesterday's) → green, down arrow, EGP
  strengthened.
- `changeAbsolute > 0` → red, up arrow, EGP weakened.
- `changeAbsolute == 0` → neutral/gray, no arrow.

This is the inverse of a naive "value went up = green" stock-ticker convention — don't
copy that instinct here.

## Architecture / folder structure

```
lib/features/exchange_rate_list/
  data/                                 # owned separately — not built in this pass
    data_source/
    models/
    repository_impl/
  domain/
    exchange_rate_entity.dart
    repository/
      exchange_rate_repository.dart
    use_cases/
      get_exchange_rates_use_case.dart
  presentation/
    bloc/
      exchange_rate_bloc.dart
      exchange_rate_events.dart
      exchange_rate_states.dart
    pages/
      exchange_rate_list_page.dart
    widgets/
      exchange_rate_header.dart          # unchanged
      update_status_row.dart             # owns its own BlocBuilder — see below
      base_currency_selector.dart        # unchanged
      exchange_rate_list_body.dart       # owns the list's BlocBuilder — see below
      exchange_rate_list_item.dart       # modified — see below
      exchange_rate_list_loading.dart    # new
      exchange_rate_list_error.dart      # new
      exchange_rate_list_empty.dart      # new
    models/
      exchange_rate_view_data.dart       # replaces the old mock exchange_rate.dart
```

### `domain/`

- `exchange_rate_entity.dart` — `ExchangeRateEntity` (`code`, `name`, `rateInEgp`,
  `changeAbsolute`, `changePercent`), plus a fixed `supportedCurrencies` list (the 5
  code/name pairs from the table above). That list is a domain-level business rule, not
  API data, so it lives here rather than in a data model.
- `repository/exchange_rate_repository.dart` — abstract contract:
  ```dart
  abstract class ExchangeRateRepository {
    Future<Either<Failure, Map<String, double>>> getLatestRates();
    Future<Either<Failure, Map<String, double>>> getHistoricalRates(DateTime date);
  }
  ```
  Both methods return **already-inverted** EGP-per-unit values, keyed by lowercase
  currency code, wrapped in `dartz`'s `Either<Failure, ...>` — **the repository
  implementation is responsible for catching exceptions and mapping them to `Failure`
  (`Left`)**, not for throwing. The EGP→foreign inversion is also a data-layer
  responsibility and must not leak into domain.
- `use_cases/get_exchange_rates_use_case.dart` — `GetExchangeRatesUseCase` takes the
  repository via a named constructor field (`GetExchangeRatesUseCase({required
  this.exchangeRateRepository})`, not a positional `const` constructor). `call()` has
  **no try/catch** — it awaits both repository methods (today's date and
  `DateTime.now().subtract(const Duration(days: 1))`) via `Future.wait`, then combines the
  two `Either` results with `flatMap`/`map` (dartz combinators) into a single
  `Either<Failure, List<ExchangeRateEntity>>`, computing `changeAbsolute`/`changePercent`
  per currency in the `Right` branch. If either call comes back `Left`, that failure
  short-circuits straight through.
- No `domain/params/` yet — this use case takes no arguments (base is always EGP, the
  currency list is fixed). Add it when a parameterized use case (e.g. historical detail)
  is needed.

### `data/` (contract only — built separately)

`repository_impl` should implement `ExchangeRateRepository` using the existing
`NetworkHelper` (`lib/core /services/network/`) to call the latest/historical URLs
(`isFullPath: true`, since these are external hosts, not the app's own API), parse the
`egp.<code>` keys for the 5 supported currencies, invert each value (`1 / rawValue`), and
**catch exceptions itself**, mapping them via `ErrorHandler.handle(error).failure` and
returning `Left(failure)` — the domain layer never sees a thrown exception, only
`Either`. Historical calls take a `DateTime` from the use case and format it as
`YYYY-MM-DD` in the URL themselves.

### `presentation/`

- `bloc/exchange_rate_events.dart` — a single `GetExchangeRateEvent` (no payload),
  dispatched both for the initial load and for pull-to-refresh/header-refresh — there's no
  separate refresh event.
- `bloc/exchange_rate_states.dart` — `ExchangeRateStates`, using the shared
  `core/enums/bloc_status.dart` `BlocStatus` enum (`initial | loading | success | failure
  | uploading | updated`, with `isInitial`/`isLoading`/etc. getters) instead of a bespoke
  per-feature status enum. Carries `List<ExchangeRateEntity> rates`, `DateTime?
  lastUpdated`, `String? errorMessage`. There's no dedicated `refreshing` or `empty`
  status — the UI derives "empty" from `status.isSuccess && rates.isEmpty`, and
  pull-to-refresh reuses `loading`.
- `bloc/exchange_rate_bloc.dart` — `ExchangeRateBloc extends Bloc<ExchangeRateEvents,
  ExchangeRateStates>`, one `on<GetExchangeRateEvent>` handler that emits `loading`, awaits
  `getExchangeRatesUseCase()`, and `.fold()`s the `Either<Failure,
  List<ExchangeRateEntity>>` result into `failure`/`success` states — no try/catch
  anywhere in presentation either, matching the use case.
- `pages/exchange_rate_list_page.dart` — a plain `StatelessWidget`; it does **not** create
  the `BlocProvider` itself (see Routing below) and does **not** hold any `BlocBuilder`
  directly — it just lays out `ExchangeRateHeader`, `UpdateStatusRow`,
  `BaseCurrencySelector`, and `ExchangeRateListBody`.
- `widgets/update_status_row.dart` and `widgets/exchange_rate_list_body.dart` each own
  their own `BlocBuilder<ExchangeRateBloc, ExchangeRateStates>` internally (with a
  `buildWhen` scoped to what they actually read — `lastUpdated` for the status row,
  `status` for the list body), rather than the page building both and passing data down.
  `ExchangeRateListBody` contains the loading/error/empty/success branching and the
  `RefreshIndicator` + `ListView.separated`, dispatching `GetExchangeRateEvent()` on
  retry/refresh.
- `widgets/exchange_rate_list_item.dart` — **drops `MiniSparkline`**: the API only
  provides 2 data points (today + yesterday), not enough for a meaningful trend line.
  Keeps the up/down arrow + colored change text, now driven by the semantics above. Takes
  a formatted `ExchangeRateViewData`, not a raw entity.
- `widgets/exchange_rate_list_loading.dart`, `exchange_rate_list_error.dart` (message +
  retry button dispatching `GetExchangeRateEvent()`), `exchange_rate_list_empty.dart` —
  simple state widgets used by `ExchangeRateListBody`.
- `models/exchange_rate_view_data.dart` — replaces the old mock `models/exchange_rate.dart`.
  Presentation-only formatter, `ExchangeRateViewData.fromEntity(ExchangeRateEntity)`,
  turning raw doubles into display strings (`"52.01"`, `"+0.32 EGP (0.63%)"`) and the
  green/red/neutral + arrow decision — keeps "no formatting logic in widgets".

### Error handling: `dartz` `Either`, repository-owned

Exceptions are caught **once**, at the repository implementation (data layer) — it maps
them to the existing `Failure` class via `ErrorHandler.handle(error).failure` and returns
`Left(failure)`. Everything above that (`GetExchangeRatesUseCase`, `ExchangeRateBloc`) is
pure `Either` plumbing with no try/catch: the use case combines two `Either` results with
`flatMap`/`map`, and the bloc consumes the final `Either` with `.fold()`.

## Routing owns the `BlocProvider`

`ExchangeRateListPage` does not create its own `BlocProvider` — `AppRouter` does, in the
`RouteName.exchangeRateList` case, wrapping the page and dispatching the initial
`GetExchangeRateEvent()` right there:
```dart
case RouteName.exchangeRateList:
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<ExchangeRateBloc>()..add(const GetExchangeRateEvent()),
      child: const ExchangeRateListPage(),
    ),
  );
```
This keeps the page itself a plain, provider-agnostic widget.

## DI wiring

This repo has no working `build_runner`/`injectable_generator` pipeline yet —
`serivice_locator.config.dart` is a hand-maintained stub, and existing `@LazySingleton`
annotations (e.g. on `DioImpl`) aren't actually processed into it. So
`GetExchangeRatesUseCase` and `ExchangeRateBloc` need to be **manually** added to that
file's `init()` — note `GetExchangeRatesUseCase` takes its repository as a **named**
argument (`GetExchangeRatesUseCase(exchangeRateRepository: gh<ExchangeRateRepository>())`),
alongside whatever registration gets added for `repository_impl`. The bloc won't resolve
at runtime until an `ExchangeRateRepository` implementation is registered too.

## Small core additions (in scope, not part of the `data` layer)

- `CommonFunctions.formatTime(DateTime)` in `core/utils/common_functions.dart` — hand-rolled
  `h:mm a` formatting for the "Updated 05:27 PM" status line (no `intl` dependency in
  `pubspec.yaml`, so don't add one for this).
- API-date-string formatting (`YYYY-MM-DD` for the historical URL) stays inside the data
  layer's `repository_impl`, since it's tied to how that layer calls the API.

## Explicitly out of scope for this pass

- Actual file creation for `domain/`, `presentation/`, or the small core additions above —
  this doc is the plan, not the implementation.
- Wiring the onboarding "Start Tracking Rates" button to navigate here — worth doing once
  Module 1 works end-to-end, but not decided yet. `main.dart`'s `initialRoute` is back to
  `RouteName.onBoarding`.
