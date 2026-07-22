# Offline Caching Layer — Module 3: Hive Persistence + Auto-Refresh

## Context

Offline support is a stated brief requirement and is described in `AI_USAGE.md` (Entry 2) as the
app's "headline feature" — but until this module there was **zero** caching: every launch fetched
live, and any network failure dropped the whole screen to an error state. `lastUpdated` was just
`DateTime.now()` held in bloc memory (never persisted), and the `UpdateStatusRow` dot was
hard-coded green regardless of connectivity.

This module adds a **Hive-backed cache at the repository layer** so the last fetched rates persist
across launches. Offline, cached data is served with an **amber** "Offline · Updated <time>"
indicator (the timestamp is the real fetch time, not "now"); when connectivity returns, the rates
**auto-refresh** via a `connectivity_plus` listener. Because both the rates list and the
currency-detail chart go through the same `GetExchangeRatesUseCase`, caching at the repository
transparently makes the 7-day chart work offline too.

## Design rule — cache lives in the repository, not the bloc

The single insertion point is `ExchangeRateRepositoryImpl.getExchangeRates`, which already wraps
everything in try/catch → `Either<String, …>`. **Write-through** on success (persist the fresh
response), **read-through** on failure (serve cache). No bloc knows about Hive; both blocs keep
calling the same use case. This mirrors the existing precedent of keeping data concerns in the
data layer (the repo already owns all error handling via `ErrorHandler`).

## Requirements → approach

| Brief requirement | How it's met |
|---|---|
| Persist last fetched rates locally | Hive box, write-through on every successful fetch (repository) |
| Serve cached data when offline | Repository read-through fallback on network failure |
| Indicator showing when data was last updated | Cache stores a `cachedAt` timestamp, surfaced as `lastUpdated`; amber dot/text when offline |
| Auto-refresh when connectivity returns | `connectivity_plus` stream → bloc re-dispatches the fetch on offline→online transition |

## Serialization choice — JSON string, no TypeAdapters

The response model (`ExchangeRateResponseModel`) is serialized with a new `toJson()` and stored as
a `jsonEncode`d **String** envelope (`{ 'data': …, 'cachedAt': ISO-8601 }`). This deliberately
avoids `hive_generator`/`TypeAdapter`s — sidestepping both Hive's dynamic-map typing on read *and*
this repo's non-working build_runner pipeline. On read, `jsonDecode` reconstructs via the existing
`ExchangeRateResponseModel.fromJson`.

## Reused contracts / utilities

- `CommonFunctions.formatDate` — cache **key** for historical days (`latest` for the `null`/latest
  call), matching how `ExchangeRateRemoteDataSourceImpl` already chooses latest vs. historical.
- `CommonFunctions.formatTime` — the "Updated <time>" display (no `intl`, same as the list screen).
- `ErrorHandler.handle(e).failure.message` — the `Left` message on a cache-miss failure. The error
  taxonomy already models `StatusCode.noInternetConnection (-6)` and `StatusCode.cacheError (-5)`.
- `AppColors.accent` (amber) for the offline dot, `AppColors.good` (green) for the online dot.

## Architecture / new + changed files

```
lib/core /services/connectivity/
  connectivity_service.dart            # abstract + connectivity_plus impl (lazySingleton)

lib/features/exchange_rates/
  domain/entity/
    exchange_rates_result.dart         # NEW: wraps {data, timestamp, isFromCache}
  data/data_source/
    exchange_rates_local_data_source.dart  # NEW: Hive read/write, kExchangeRatesCacheBox
  data/models/
    exchange_rates_response_model.dart # + toJson(); fromJson hardened for Hive maps
  data/repository_impl/
    exchange_rates_repository_impl.dart# + local data source, write-through / read-through
  domain/repository/…                  # return type → Either<String, ExchangeRatesResult>
  domain/use_cases/…                   # return type passthrough change
  presentation/bloc/                   # + ConnectivityChangedEvent, isOffline state,
                                       #   connectivity subscription, auto-refresh
  presentation/widgets/update_status_row.dart  # amber dot + "Offline · Updated <time>"

lib/features/currency_detail/presentation/
  bloc/                                # + ConnectivityChangedEvent, isOffline, .data unwrap,
                                       #   remembers last code, auto-refresh on reconnect
  widgets/detail_offline_indicator.dart# NEW: amber "Offline · showing cached data" row
  pages/currency_detail_page.dart      # renders the indicator under the header
```

### `domain/entity/exchange_rates_result.dart`

```dart
class ExchangeRatesResult {
  const ExchangeRatesResult({required this.data, required this.timestamp, required this.isFromCache});
  final ExchangeRateResponseEntity data;
  final DateTime timestamp;   // now() if live, cachedAt if served from cache
  final bool isFromCache;
}
```

The wrapper is the reason the bloc can show an accurate timestamp: instead of blindly setting
`lastUpdated = DateTime.now()` on success, it reads `latestResult.timestamp`, which is the real
fetch time even when the data came from cache.

### `data/data_source/exchange_rates_local_data_source.dart`

- Box name constant `kExchangeRatesCacheBox = 'exchange_rates_cache'`, opened once in `main.dart`.
- `cacheExchangeRates(DateTime?, ExchangeRateResponseModel)` — writes the JSON envelope.
- `getCachedExchangeRates(DateTime?)` → `CachedExchangeRates? {data, cachedAt}` (null on miss or
  malformed).
- Accesses the already-open box via `Hive.box(kExchangeRatesCacheBox)`, so it needs **no injected
  `Box`** — keeps DI simple. Still `@Injectable(as: …)` for consistency.

### `core /services/connectivity/connectivity_service.dart`

```dart
abstract class ConnectivityService {
  Stream<bool> get onStatusChange;   // true = online
  Future<bool> isConnected();
}
```
`connectivity_plus` v6 emits `List<ConnectivityResult>`; online = the list contains anything other
than `ConnectivityResult.none`. Registered as a `lazySingleton` (like `NetworkHelper`).

### Repository flow

1. `try`: remote fetch → `cacheExchangeRates(dateTime, model)` → `Right(result(now, isFromCache: false))`.
2. `catch`: `getCachedExchangeRates(dateTime)` → hit → `Right(result(cachedAt, isFromCache: true))`;
   miss → `Left(ErrorHandler.handle(e).failure.message)`.

Fallback triggers on **any** failure with a cache hit (resilient); the offline *indicator* is
driven separately by live connectivity.

### Bloc changes (both `ExchangeRateBloc` and `CurrencyDetailBloc`)

- Inject `ConnectivityService`; subscribe to `onStatusChange` in the constructor and seed the
  initial status via `isConnected()`; cancel the subscription in `close()`.
- New `ConnectivityChangedEvent(isOnline)` → emits `isOffline: !isOnline`; on an **offline→online**
  transition it re-dispatches the fetch (`GetExchangeRatesEvent` / `GetCurrencyHistoryEvent(code)`).
- Response unwrap: the combine now uses `result.data`. `ExchangeRateBloc` sets
  `lastUpdated = latestResult.timestamp`. `CurrencyDetailBloc` remembers `_lastCode` so it can
  re-fetch the same currency's history on reconnect.

### UI indicators (amber dot + inline text — chosen treatment)

- **List** — `UpdateStatusRow` dot is `state.isOffline ? AppColors.accent : AppColors.good`; text
  is `'Offline · Updated <time>'` when offline, else `'Updated <time>'`. `buildWhen` also watches
  `isOffline`.
- **Detail** — new `DetailOfflineIndicator` renders an amber dot + "Offline · showing cached data"
  under the header when `CurrencyDetailBloc.isOffline`, and nothing when online.

## Dependencies (pubspec.yaml)

```yaml
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.1.0
```
No `hive_generator` (JSON-string serialization). Resolved versions at build time: hive 2.2.3,
hive_flutter 1.1.0, connectivity_plus 6.1.5.

## Bootstrap & DI

- `main.dart` — after `WidgetsFlutterBinding.ensureInitialized()` and before `configureInjection()`:
  `await Hive.initFlutter(); await Hive.openBox(kExchangeRatesCacheBox);`
- `service_locator.config.dart` is hand-maintained (no working build_runner) — hand-add:
  `ConnectivityService → ConnectivityServiceImpl` (lazySingleton),
  `ExchangeRateLocalDataSource → …Impl` (factory), the repo factory now takes remote **+** local,
  and both bloc factories now also take `ConnectivityService`.

## Data flow

- **Online** → remote OK → write-through → `Right(live, now)`. `success`, green dot, `Updated <time>`.
- **Offline, cache present** → remote throws → read cache → `Right(cache, cachedAt)`. `success`,
  amber dot, `Offline · Updated <cachedAt>`.
- **Offline, no cache** (cold first launch offline) → cache miss → `Left(message)` → error widget.
- **Reconnect** → connectivity stream → offline→online → auto re-dispatch fetch → live replaces cache.
- **Detail chart offline** → same use case → historical days served from cache → chart renders +
  amber offline indicator.

## Verification

1. `flutter pub get` → `flutter analyze` (clean beyond pre-existing unrelated warnings) →
   `flutter build`.
2. Online: rates load, green dot, "Updated <time>".
3. Airplane mode + pull-to-refresh → last rates persist, amber dot, "Offline · Updated <time>"
   (original fetch time, not now).
4. Cold launch offline after a prior online session → cached rates render immediately.
5. Cold launch offline with no prior cache → error state.
6. Re-enable connectivity → list auto-refreshes with no user action (dot → green, timestamp bumps).
7. Detail screen offline → chart renders from cached history + amber offline indicator.

## Explicitly out of scope

- No cache expiry/TTL or eviction — newest successful fetch overwrites per key.
- No `hive_generator`/`TypeAdapter`s (JSON-string serialization instead).
- No change to the API, endpoints, or the two-call (latest + yesterday) combine logic.
- No offline handling for onboarding (fully local/static already).
