# Testing Plan — `axis`

A practical plan for adding **unit tests** and **bloc tests** to the app using
[`mocktail`](https://pub.dev/packages/mocktail) and
[`bloc_test`](https://pub.dev/packages/bloc_test).

> **Status:** ✅ Implemented — 73 tests passing (`flutter test`), including
> widget tests. This document also serves as the reference for the existing
> suite under `test/`.

---

## 1. Overview & Goals

The app has two Bloc-driven features built on clean architecture
(`data` / `domain` / `presentation`), `dartz` `Either` error handling, Hive
caching, and a `ConnectivityService`:

- **`exchange_rates`** — fetches latest + yesterday rates, computes per-currency
  change, serves cache when offline.
- **`currency_detail`** — builds a 7-day history for one currency, caches it,
  falls back to cache on error.

**What we test (this plan):**

- Pure domain logic — rate math, view-model mapping, state getters, formatters.
- Data layer — repository (online/offline/cache fallback), use case, local data
  sources (Hive), model JSON.
- Blocs — full state-transition coverage with `bloc_test`.

**Widget / UI tests** are included: presentation widgets for both features,
driven by mocked blocs (`MockBloc`) and rendered through a shared harness that
wraps `ScreenUtilInit`, a `MaterialApp`, and a fake asset bundle (so
`SvgPicture.asset` flags resolve without real asset files). Full end-to-end page
navigation tests remain out of scope.

**Why it matters:** the highest-risk logic is the currency math (rate inversion,
trend direction, percent change) and the offline/cache fallback branching — both
easy to break silently and both fully unit-testable.

> ⚠️ The existing `test/widget_test.dart` is the **stale default Flutter counter
> template** (references a non-existent `MyApp` counter). It fails today and must
> be **deleted / replaced**.

---

## 2. Setup

### 2.1 Add dev dependencies

`mocktail` and `bloc_test` are **not** currently present. Add to
`pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0
  build_runner: ^2.4.13
  injectable_generator: ^2.6.2

  # Testing
  bloc_test: ^10.0.0   # compatible with flutter_bloc ^9.1.1
  mocktail: ^1.0.4
```

Then:

```bash
flutter pub get
```

### 2.2 Proposed `test/` structure (mirrors `lib/`)

```
test/
  helpers/
    mocks.dart            # all Mock<X> classes (incl. MockBloc) + fallbacks
    fixtures.dart         # entity/model builders (responses, view data)
    hive_test_setup.dart  # temp Hive box init/teardown helpers
    widget_harness.dart   # ScreenUtilInit + MaterialApp + fake asset bundle
  core/
    common_functions_test.dart
  features/
    exchange_rates/
      domain/currency_rate_change_test.dart
      domain/get_exchange_rates_use_case_test.dart
      data/exchange_rates_repository_impl_test.dart
      data/exchange_rates_local_data_source_test.dart
      data/exchange_rates_response_model_test.dart
      presentation/exchange_rate_bloc_test.dart
      presentation/exchange_rates_view_data_test.dart
      presentation/widgets/exchange_rate_leaf_widgets_test.dart
      presentation/widgets/exchange_rates_list_body_test.dart
      presentation/widgets/update_status_row_test.dart
    currency_detail/
      data/currency_history_local_data_source_test.dart
      presentation/currency_detail_bloc_test.dart
      presentation/currency_detail_states_test.dart
      presentation/widgets/currency_detail_widgets_test.dart
```

**Suggested implementation order:** pure units → data layer → blocs → widgets.

---

## 3. Gotchas — read before writing any test

These are project-specific traps discovered in the codebase. Ignoring them will
cost hours.

1. **Trailing-space core directory.** The folder is literally named `core `
   (with a trailing space). Imports of core services **must** use the
   URL-encoded form:

   ```dart
   import 'package:axis/core%20/services/connectivity/connectivity_service.dart';
   import 'package:axis/core%20/enums/bloc_status.dart';
   ```

2. **Blocs eagerly subscribe to connectivity in their constructors.** Both
   `ExchangeRateBloc` and `CurrencyDetailBloc` call, at construction time:

   ```dart
   connectivityService.onStatusChange.listen(...);
   connectivityService.isConnected().then(...);
   ```

   Every bloc test **must stub both**, and — this matters — `isConnected()`
   should return a **future that never completes**, so the constructor's eager
   `isConnected().then(...)` does not fire a phantom `ConnectivityChangedEvent`
   that races with `act`. (A resolving future was found in practice to land
   *after* the `act` event, flip `wasOffline`, and trigger an unwanted
   auto-refresh into the unstubbed use case.) Tests drive connectivity
   explicitly by dispatching `ConnectivityChangedEvent` themselves:

   ```dart
   when(() => connectivity.onStatusChange)
       .thenAnswer((_) => const Stream<bool>.empty());
   when(() => connectivity.isConnected())
       .thenAnswer((_) => Completer<bool>().future); // never completes
   ```

3. **`GetExchangeRatesUseCase` is a callable class** (`call(DateTime?)`). Stub
   with mocktail via `when(() => mock(any()))` / `when(() => mock(null))`. Using
   `any()` for the nullable `DateTime?` positional requires a fallback:

   ```dart
   setUpAll(() => registerFallbackValue(DateTime(2020)));
   ```

4. **Call counts per bloc event:**
   - `ExchangeRateBloc.getExchangeRateList` fires **2** use-case calls:
     `useCase(null)` (latest) and `useCase(yesterday)`.
   - `CurrencyDetailBloc.getCurrencyHistory` fires **7** use-case calls
     (`Future.wait` over days −6..−1 plus `null` for latest).

     Stubs must cover every argument form (use `any()` unless asserting a
     specific date).

5. **Local data sources use static `HiveStorage` boxes** (not injected) — they
   **cannot** be mocked with mocktail. Test them against a **temporary real Hive
   box** instead (see §4.3).

6. **`RateTrend` semantics are inverted vs. the raw number.** `changeAbsolute =
   rate - previousRate` where `rate = 1 / quote`. So rate **down** (bigger
   quote) → `strengthening`; rate **up** (smaller quote) → `weakening`; equal →
   `unchanged`. When writing fixtures, remember a **smaller** quote means a
   **larger** rate — easy to flip when labelling test cases.

---

## 4. Shared helpers

### 4.1 `helpers/mocks.dart`

Declare one mock per collaborator (`extends Mock implements X`):

```dart
class MockGetExchangeRatesUseCase extends Mock implements GetExchangeRatesUseCase {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockCurrencyHistoryLocalDataSource extends Mock implements CurrencyHistoryLocalDataSource {}
class MockExchangeRateRepository extends Mock implements ExchangeRateRepository {}
class MockExchangeRateRemoteDataSource extends Mock implements ExchangeRateRemoteDataSource {}
class MockExchangeRateLocalDataSource extends Mock implements ExchangeRateLocalDataSource {}
class MockNetworkHelper extends Mock implements NetworkHelper {}
```

Provide a small connectivity-stub helper so every bloc test stays honest:

```dart
void stubConnectivity(MockConnectivityService c, {bool online = true}) {
  when(() => c.onStatusChange).thenAnswer((_) => const Stream<bool>.empty());
  when(() => c.isConnected()).thenAnswer((_) async => online);
}
```

Register fallbacks in `setUpAll`:

```dart
setUpAll(() {
  registerFallbackValue(DateTime(2020));
});
```

### 4.2 `helpers/fixtures.dart`

Builders so each test reads clearly:

```dart
ExchangeRateResponseModel buildResponse({
  String date = '2026-07-22',
  double usd = 48.0, double eur = 52.0, double gbp = 61.0,
  double sar = 12.8, double jpy = 0.33,
}) => ExchangeRateResponseModel.fromJson({
  'date': date,
  'egp': {'usd': usd, 'eur': eur, 'gbp': gbp, 'sar': sar, 'jpy': jpy},
});

ExchangeRatesResult buildResult({bool isFromCache = false, DateTime? at}) =>
    ExchangeRatesResult(
      data: buildResponse(),
      timestamp: at ?? DateTime(2026, 7, 22),
      isFromCache: isFromCache,
    );
```

> Note: the API returns `egp[code]` as **EGP-per-1-foreign-unit** (e.g.
> `usd: 48` ≈ raw quote). App logic inverts it (`rate = 1 / quote`). Keep fixture
> values in raw form so the math under test matches production.

### 4.3 `helpers/hive_test_setup.dart` (temp box for local-source tests)

```dart
late Directory tempDir;

Future<Box> openTempBox(String name) async {
  tempDir = await Directory.systemTemp.createTemp('axis_test');
  Hive.init(tempDir.path);
  return Hive.openBox(name);
}

Future<void> closeTempBox() async {
  await Hive.deleteFromDisk();
  await tempDir.delete(recursive: true);
}
```

Use `TestWidgetsFlutterBinding.ensureInitialized()` at the top of Hive-backed
suites. Open the box name the source expects
(`HiveStorage.exchangeRatesCacheBox()` / `HiveStorage.currencyHistoryBox()`)
inside `setUp`, tear down after each test.

---

## 5. Pure unit tests (no mocks — do these first)

Fast, deterministic, and cover the riskiest logic.

### 5.1 `CurrencyRateChange.fromQuotes`
- `rate == 1 / todayQuote`.
- `yesterdayQuote` **null** or **0** → previousRate falls back to today →
  `changeAbsolute == 0`, trend `unchanged`.
- Today's rate **higher** than yesterday's (quote lower) → `weakening`.
- Today's rate **lower** (quote higher) → `strengthening`.
- `changePercent == changeAbsolute / previousRate * 100`.
- Guard: `previousRate == 0` → `changePercent == 0`.

### 5.2 `CurrencyRateChange.fromResponses`
- Iterates `kSupportedCurrencyCodes` (`USD, EUR, GBP, SAR, JPY`).
- **Skips** any code whose latest quote is `0` / missing.
- Pairs each latest quote with the matching `previous` quote.

### 5.3 `ExchangeRateViewData.fromChange`
- `name` / `flagAsset` resolved from `_currencyMeta`.
- `color`: `strengthening → AppColors.good`, `weakening → AppColors.critical`,
  `unchanged → AppColors.textTertiary`.
- `rateLabel` — 2 decimals.
- `changeLabel` — `"<abs> EGP (<abs>%)"` using **absolute** values.
- `trendIcon` — up / down / `null` for `unchanged`.

### 5.4 `CurrencyDetailStates` computed getters
- Empty history → `low`, `high`, `range` all `null`; `weekTrend == unchanged`.
- Single point → `low == high`, `range == 0`; `weekTrend == unchanged` (needs ≥2).
- Ascending multi-point (last > first) → `weekTrend == weakening`.
- Descending multi-point (last < first) → `weekTrend == strengthening`.
- `range == high - low`.

### 5.5 `CommonFunctions`
- `formatDate` → zero-padded `YYYY-MM-DD` (e.g. `2026-07-05`).
- `formatTime` → 12-hour `h:mm AM/PM` (verify midnight `12:00 AM`, noon
  `12:00 PM`, minute padding).
- `formatShortDate` → `Mon D` (e.g. `Jul 5`).

---

## 6. Data-layer unit tests (`mocktail`)

### 6.1 `GetExchangeRatesUseCase.call`
- Delegates to `repository.getExchangeRates(dateTime)` and returns its `Either`
  unchanged.
- `verify` the repo was called with the exact `DateTime?` passed in.

### 6.2 `ExchangeRateRepositoryImpl.getExchangeRates`

Mock `remote`, `local`, `connectivity`. Four branches:

| # | Condition | Expected |
|---|-----------|----------|
| 1 | offline + cache present | `Right`, `isFromCache: true`, `timestamp == cachedAt`; **remote never called** |
| 2 | offline + no cache | `Left('No internet connection')` |
| 3 | online + remote success | `Right`, `isFromCache: false`; **`cacheExchangeRates` verified called** (write-through) |
| 4 | online + remote throws | falls back to cache → `Right isFromCache: true`; if no cache → `Left(ErrorHandler.handle(e).failure.message)` |

For (1)/(4) stub `local.getCachedExchangeRates(...)` to return a
`CachedExchangeRates`. Use `verifyNever(() => remote.getExchangeRates(any()))`
for the offline case.

### 6.3 Local data sources (temp Hive box — see §4.3)

**`ExchangeRateLocalDataSource`:**
- `cacheExchangeRates` then `getCachedExchangeRates` **round-trips** data +
  `cachedAt`.
- Unknown key → `null`.
- Corrupt / non-`String` stored value → `null` (the `catch` path).
- Keying: `null` date → `'latest'`; a date → `formatDate(date)`.

**`CurrencyHistoryLocalDataSource`:**
- `cacheHistory` then `getCachedHistory` round-trips date + rate for each point.
- Unknown code → `null`; corrupt JSON → `null`.

### 6.4 `ExchangeRateResponseModel` JSON
- `fromJson` → `toJson` round-trip preserves `date` and all five rates.
- Missing `egp` → `egp == null`.
- Missing individual rate fields default to `0.0`; missing `date` → `""`.
- `EgpRatesEntity operator[]` maps `'USD'..'JPY'` correctly; unknown code →
  `null`.

---

## 7. Bloc tests (`bloc_test`)

Standard shape: `build` constructs the bloc with stubbed collaborators, `act`
dispatches events, `expect` asserts the **ordered** state list. Always
`stubConnectivity(...)` in `build`.

### 7.1 `ExchangeRateBloc`

```dart
blocTest<ExchangeRateBloc, ExchangeRateStates>(
  'emits [loading, success] with list + lastUpdated on success',
  setUp: () {
    stubConnectivity(connectivity, online: true);
    when(() => useCase(any())).thenAnswer((_) async => Right(buildResult()));
  },
  build: () => ExchangeRateBloc(useCase, connectivity),
  act: (b) => b.add(const GetExchangeRatesEvent()),
  expect: () => [
    isA<ExchangeRateStates>().having((s) => s.status, 'status', BlocStatus.loading),
    isA<ExchangeRateStates>()
        .having((s) => s.status, 'status', BlocStatus.success)
        .having((s) => s.exchangeRateList, 'list', isNotEmpty)
        .having((s) => s.lastUpdated, 'lastUpdated', isNotNull),
  ],
);
```

Cases to cover:
- **Success** — as above (stub both `useCase(null)` and `useCase(yesterday)` to
  `Right`).
- **Failure** — one call returns `Left('msg')` → `[loading, failure]` with
  `errorMessage == 'msg'`.
- **Goes offline** — `add(ConnectivityChangedEvent(false))` → state with
  `isOffline: true`.
- **Offline → online auto-refresh** — `seed` an offline state, emit
  `ConnectivityChangedEvent(true)`, expect a re-fired `GetExchangeRatesEvent`
  (`loading` → `success`). Use `seed:` and `skip:` to isolate.

### 7.2 `CurrencyDetailBloc`

Cases to cover:
- **Success** — all 7 calls `Right` → `[loading, success]` with up to 7
  `CurrencyHistoryPoint`s where `rate == 1 / quote`; points with `null`/`0`
  quotes are skipped. `verify(() => history.cacheHistory(any(), any()))` when
  online.
- **Error + cached fallback** — a `Left` occurs but
  `history.getCachedHistory(code)` returns a **non-empty** list →
  `[loading, success(history: cached)]`.
- **Error + no cache** — `Left` and cache empty/`null` → `[loading, failure]`
  with `errorMessage`.
- **Offline → online refresh** — after a `GetCurrencyHistoryEvent(code)` set
  `_lastCode`, emitting `ConnectivityChangedEvent(true)` from offline re-fires
  `GetCurrencyHistoryEvent` with the same code.
- **No caching while offline** — with `isOffline: true`,
  `verifyNever(() => history.cacheHistory(any(), any()))`.

---

## 7b. Widget tests

Presentation widgets are rendered through `helpers/widget_harness.dart`
(`pumpWithHarness`), which wraps the widget in `ScreenUtilInit` (design size
`390×844`, so `.w`/`.h`/`.sp`/`.r` resolve), a `MaterialApp`/`Scaffold`, and a
`DefaultAssetBundle` backed by a `FakeAssetBundle` returning a minimal valid SVG
— this lets `SvgPicture.asset` flags render without shipping real asset files
into the test bundle.

Bloc-backed widgets use `MockExchangeRateBloc` / `MockCurrencyDetailBloc`
(`MockBloc` from `bloc_test`, in `helpers/mocks.dart`), seeded per test with:

```dart
whenListen(bloc, const Stream<ExchangeRateStates>.empty(), initialState: state);
```

then provided via `BlocProvider.value`.

**Leaf widgets (no bloc):**
- `ExchangeRateHeader` — renders title + refresh icon; tap fires `onRefresh`.
- `ExchangeRateListError` — shows the message and a `Retry` button; tap fires
  `onRetry`.
- `ExchangeRateListEmpty` — renders the empty message.
- `ExchangeRateListLoading` — renders shimmer rows.
- `CurrentRateCard` / `StatCard` — render their text, values, and optional icon.

**Bloc-driven widgets:**
- `ExchangeRateListWidget` — one test per `BlocStatus`: loading → loading list,
  failure → error widget + message, success+empty → empty widget, success+data →
  one `ExchangeRateListItem` per rate. Tapping `Retry` in the error state
  `verify`s a `GetExchangeRatesEvent` is added to the bloc.
- `UpdateStatusRow` — `Updated —` with no timestamp, `Updated <time>` online,
  `Offline · Updated <time>` offline.
- `DetailOfflineIndicator` — hidden when online, shows `Offline .` when offline.

---

## 8. Running & Verifying

```bash
# All tests
flutter test

# A single feature / file
flutter test test/features/exchange_rates/

# With coverage
flutter test --coverage
# → coverage/lcov.info  (optional HTML: genhtml coverage/lcov.info -o coverage/html)
```

**Definition of done for this phase:**
- Pure-logic, data-layer, and bloc suites above are green.
- The stale `test/widget_test.dart` is removed.
- `flutter test` passes from a clean checkout after `flutter pub get`.

**Optional follow-ups (out of scope here):**
- Widget tests for pages/widgets (needs ScreenUtil + asset/font harness).
- CI workflow running `flutter test --coverage` on every push.
