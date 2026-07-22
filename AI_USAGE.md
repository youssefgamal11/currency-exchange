# AI Usage Log

This document tracks how AI was used while building the Currency Exchange Tracker, from
planning through implementation — both Claude (via Claude Code) and Figma's AI design tool
(Figma Make). It is updated in the same commits as the code it describes, so entry order and
commit history should line up.



## How entries are written

Every meaningful prompt gets an entry with:

- **Prompt** — what was actually asked (trimmed of restated context, kept verbatim otherwise)
- **Model returned** — a short summary of what came back (full diffs live in the commit, not here)
- **Decision** — Accepted / Edited / Rejected
- **Why** — the actual reasoning for that call

Entries are grouped below by feature/area — expand a section to see its entries. Entry
numbers are global (not per-section) so cross-references between entries still resolve.



<details>
<summary><strong>Design Foundations</strong> — cross-screen visual direction (Entries 1–2)</summary>

---

## Entry 1 — 2026-07-21

**Tool:** Figma Make (Figma's AI design generator)

**Prompt:** Asked Figma AI to generate three screens for the task — an onboarding screen, the
exchange rates list, and the currency detail screen with a 7-day history chart — covering the
requirements from the assessment brief (5 currency pairs vs. EGP, daily change, offline
indicator, 7-day chart).

**Model returned:** Three screens (onboarding/marketing screen, exchange rates list, currency
detail) in a dark fintech visual style, with sample data, a 7-day line chart, and stat cards for
current rate / daily change / yesterday's rate / last update.

**Decision:** Edited. Used the generated screens as the visual direction but corrected several
details before treating them as final: the list's rate-number coloring was inconsistent between
runs with no clear rule, and the chart's y-axis value labels were broken (repeating/nonsensical
numbers unrelated to the actual rate range) in every export.

**Why:** The overall layout, card style, and color language were solid enough to build from, but
a couple of visual bugs weren't worth carrying into the actual spec — consistent color-coding
and correct axis values matter for a data-accuracy-sensitive app like this one. Took screenshots
of the corrected direction and handed them to Claude Code to turn into a full design-spec
artifact (all required states: loading, error, empty, offline) before writing any Flutter code.

---

## Entry 2 — 2026-07-21

**Prompt:** Attached UI design reference screenshots (onboarding/marketing screen, exchange
rates list, currency detail) to Claude and asked for the app's visual design to match them — a
single onboarding screen plus all required states for the other two screens.

**Model returned:** An interactive HTML mockup published as an Artifact: onboarding (amber/mint-
green/coral palette, floating rate chips, flag icons, inline sparklines), the Exchange Rates
List, and the Currency Detail screen, covering every required state (loading, error, empty,
offline).

**Decision:** Edited, over a couple of rounds. Closed specific gaps against the reference each
time: the detail screen's page title, the "rate is inverted from the API" info banner,
inconsistent gold coloring on rate numbers, and the onboarding hero having only 2 of 4 floating
chips.

**Why:** Matching a concrete, approved reference beats iterating on an original concept — closed
each named gap directly rather than re-guessing at the whole design again.

---

</details>

<details>
<summary><strong>Onboarding Screen</strong> (Entries 3–9)</summary>

---

## Entry 3 — 2026-07-21

**Prompt:** Asked Claude (in plan mode) to design the onboarding screen's implementation —
extracting colors into `AppColors`, fonts/text styles into `AppTextStyle`, and flag SVGs, before
writing any screen code.

**Model returned:** Explored the existing stub files (`AppColors` had one placeholder color,
`AppTextStyle` referenced fonts that didn't exist, `ImgPath` pointed at a missing SVG, no
`assets/` folder existed at all), then a full plan: palette + type scale extracted from the
approved mockup, and three open decisions — font sourcing (`google_fonts` vs. self-provided
files), flag sourcing (a flag-icon package vs. self-provided SVGs), and whether to keep the
existing terse text-style naming convention (`eb16`, `b11`) vs. switch to semantic names.

**Decision:** Edited. Chose to supply the actual Inter `.ttf` files and flag SVGs directly rather
than add `google_fonts` or a flag package dependency; kept the terse naming convention.

**Why:** Bundling real font/flag files locally keeps the app fully offline from first launch —
`google_fonts`'s default runtime-fetch-and-cache behavior would have meant a cold, offline first
launch could silently fall back to the system font, which is a real tension for an app whose
headline feature is offline support. Keeping the existing naming convention avoided introducing a
second style before a second real screen existed to justify it.

---

## Entry 4 — 2026-07-21

**Prompt:** Supplied the Inter font files and asked Claude to pick the most-useful weights (even
for future screens) and wire them into the project; later supplied the flag SVGs and asked to
wire their paths.

**Model returned:** Copied Inter's 18pt static instance (Regular/Medium/SemiBold/Bold/ExtraBold)
into `assets/fonts/`, wrote the full `AppColors` palette and `AppTextStyle` type scale, wired
`pubspec.yaml`'s `fonts:` block, then later wrote `ImgPath` flag constants and the `assets:`
entry once the SVGs landed in `assets/icons/flags/`.

**Decision:** Accepted, with one gap caught proactively: the Egypt flag (`eg`/`egy.svg`) was
initially missing since only the 5 target-currency flags had been supplied — flagged before
writing any code that referenced it, rather than shipping a broken asset reference.

**Why:** Verified via `flutter pub get`/`flutter analyze` after each step rather than batching
everything then debugging at the end.

---

## Entry 5 — 2026-07-21

**Prompt:** Asked Claude to implement the onboarding screen (step 6 of the plan), but with
constraints: separate widgets in a `widgets/` folder, not private classes, and fewer separate
widgets overall — treating "flag + name + amount" as one reusable item fed different data rather
than one bespoke widget per currency.

**Model returned:** Public widget files (`BrandLockup`, `CurrencyRateChip`, `OnboardingHero`,
`OnboardingHeadline`, `FeaturePillsRow`, `CurrencyFlagRow`, `PrimaryCtaButton`), with
`CurrencyRateChip` as the one reusable "chip" fed different flag/code/rate data 4 times in the
hero instead of 4 near-identical widgets.

**Decision:** Accepted. During visual verification (ran the app on an iOS simulator, screenshotted
it) caught a real layout bug — the hero's `Stack` had no explicit width, so it collapsed to fit
only the center badge and all 4 chips bunched up overlapping instead of reaching the corners.
Fixed with `width: double.infinity` on the hero's `SizedBox`, rebuilt, reconfirmed clean.

**Why:** The consolidation request matches good Flutter practice (data-driven widgets over
copy-pasted near-duplicates); the width bug was exactly the kind of thing that only surfaces by
actually running the app, not by reading the code, which is why it's part of the normal
verification loop here rather than skipped.

---

## Entry 6 — 2026-07-21

**Prompt:** Provided a screenshot and asked to refactor `OnboardingHero` to match it — a mini
rates-list preview card with the 4 floating chips overlapping its corners/edges, instead of an
isolated center badge in empty space.

**Model returned:** Rebuilt the hero as a preview card (EGP header + 5 `MiniCurrencyRow` entries,
a new shared row widget) with the 4 chips positioned to peek over its edges via small negative
offsets — extracted a shared `MiniSparkline` widget so the sparkline painter wasn't duplicated
between the chip and the new row widget.

**Decision:** Edited/reverted. Verified against the screenshot (chips do partially cover a couple
of row labels, same as the reference) and flagged that legibility tradeoff explicitly rather than
silently shipping it. The hero was later reverted back to the simpler center-badge version
directly in the editor, ahead of the next redesign request (Entry 7).

**Why:** Matching the reference took priority over the usual instinct to "fix" the overlap-on-text
issue this time, but it was still worth naming the tradeoff out loud rather than assuming it was
fine.

---

## Entry 7 — 2026-07-21

**Prompt:** Provided a screenshot and asked to make `CurrencyRateChip` match its design — a
horizontal layout (flag+code left, sparkline middle, rate+change right) instead of the original
vertical chip.

**Model returned:** Rebuilt `CurrencyRateChip` to wrap the existing `MiniCurrencyRow` content
inside chip-style decoration, reusing the row layout instead of duplicating it. Verification (ran
the app, screenshotted) caught a 1.4px `RenderFlex` overflow inside the narrower chip width.

**Decision:** Accepted, with the overflow fixed by trimming internal gap/sparkline sizes (saved
~8px of width, comfortably clearing the 1.4px overflow) rather than widening the chip past what
the hero's corner-positioning math could safely fit.

**Why:** Reusing `MiniCurrencyRow` instead of re-implementing the row layout a second time avoided
a second place for that logic to drift out of sync.

---

## Entry 8 — 2026-07-21

**Prompt:** "make OnboardingHero a container that have colum of nb..." — message was cut off
mid-send. Claude asked what the column should contain rather than guessing; the answer was "a
column of five currencies."

**Model returned:** Replaced the floating/rotated `Stack` layout with a plain `Container` wrapping
a `Column` of all 5 `CurrencyRateChip`s (adding EUR, which previously had no floating chip),
full-width, no rotation.

**Decision:** Accepted. Simplified `CurrencyRateChip` itself in the same pass — dropped the now-
unused `rotation` parameter and fixed narrow width, since the chip's only remaining use case was
this full-width column.

**Why:** Asked for clarification instead of guessing at the cut-off instruction, since "column of
nb" was genuinely ambiguous and guessing wrong would have meant redoing real layout work.

---

## Entry 9 — 2026-07-21

**Prompt:** Asked to make the rate value's "=" prefix white while the rate number itself stays
accent-colored, using rich text; separately, asked to rename `PrimaryCtaButton` to `PrimaryButton`
and rebuild it using Flutter's `ElevatedButton`.

**Model returned:** Changed the plain colored `Text` to `Text.rich`/`TextSpan` so only the rate
value inherits the accent color while `"= "` inherits the base white style. Renamed the button
file/class and rebuilt it on `ElevatedButton` using the `Ink` + gradient pattern (since
`ElevatedButton.backgroundColor` doesn't support gradients directly), preserving the amber
gradient fill.

**Decision:** Accepted as specified — both were precise, unambiguous instructions with a single
correct implementation, executed directly.

**Why:** No judgment call needed beyond picking the standard Flutter pattern for gradient fills
on an `ElevatedButton`, which was worth a brief internal note but not a design decision to weigh.

---

</details>

<details>
<summary><strong>Exchange Rate List</strong> (Entries 10–13)</summary>

---

## Entry 10 — 2026-07-21

*(Entries 10–12 reconstructed from commit history/diffs and `exchange_rate_list.md`, not
from a live transcript — see note below.)*

**Prompt (reconstructed):** Asked Claude to build the Exchange Rate List screen's UI, same
scope discipline as onboarding — design-token-driven layout, hardcoded mock data, no Bloc,
no real navigation wiring, using the approved reference screenshot (header + refresh
button, "live" status dot, EGP base-currency selector pill, scrollable list of rate cards
with flag/code/name, sparkline, rate, and colored daily-change line).

**Model returned:** `exchange_rate_list/presentation/` with `models/exchange_rate.dart`
(mock `ExchangeRate` data class), `exchange_rate_header.dart`, `update_status_row.dart`,
`base_currency_selector.dart`, `exchange_rate_list_item.dart`, and
`exchange_rate_list_page.dart` wiring them together with a hardcoded 5-currency list
(USD/EUR/GBP/SAR/JPY). Promoted `MiniSparkline` out of the onboarding feature into
`lib/features/_shared/widgets/` since both screens needed the same trend-line painter.
Registered `RouteName.exchangeRateList` without wiring anything to navigate to it yet
(commits `72d6116`, `27d68e5`).

**Decision:** Accepted.

**Why:** Reused the onboarding pattern deliberately (design tokens, mock data, no state
management yet) to keep the UI and data-wiring concerns separate — matches Entry 3's
reasoning for not mixing design decisions with implementation ones.

---

## Entry 11 — 2026-07-21

**Prompt (reconstructed):** Asked Claude to plan and implement "Module 1" — wiring the
Exchange Rate List screen to the real currency-rates API
(`latest.currency-api.pages.dev`), restructuring the feature into clean
architecture (`data`/`domain`/`presentation`) matching the rest of the app, as a real
`flutter_bloc` feature with loading/error/empty states and pull-to-refresh.

**Model returned:** Rewrote `exchange_rate_list.md` from a UI-only doc into a full API-
integration plan (API reference table, EGP-per-unit inversion math, the
strengthening-is-green/weakening-is-red color semantics, folder structure, DI wiring
notes), then implemented it: `core/enums/bloc_status.dart` (shared `BlocStatus` enum
instead of a bespoke per-feature status), `ApiUrls.currencyApiLatestEgp`/
`currencyApiHistoricalEgp` in `end_points.dart`, `CommonFunctions.formatTime`/`formatDate`,
domain entities/repository contract/use case (two `Either`-returning repository calls
combined via `dartz`'s `flatMap`/`map`, no try/catch outside the repository impl), the
`ExchangeRateBloc`/events/states, and new `exchange_rate_list_loading.dart`/
`exchange_rate_list_error.dart`/`exchange_rate_list_empty.dart` state widgets — dropping
`MiniSparkline` from the real list item since the API only gives 2 data points (today +
yesterday), not enough for a meaningful trend line.

**Decision:** Accepted.

**Why:** Documenting the API's inverted-quote convention and the (counter-intuitive)
color/arrow semantics in the plan doc *before* implementing avoided the "which way is
green" mistake being made silently in code — matches the project's practice of writing a
design/implementation spec before touching Flutter code (Entry 1, Entry 3).

---

## Entry 12 — 2026-07-22

**Prompt (reconstructed):** Asked Claude to refactor the feature: rename `exchange_rate`
→ `exchange_rates` consistently (folder, files, classes) to match the plural feature name
used elsewhere, and address rough edges — proper error messages instead of placeholder
strings, a real loading skeleton instead of a spinner, and lock the app to portrait since
the UI wasn't designed for landscape.

**Model returned:** Renamed the feature folder and its data/domain/presentation files to
the `exchange_rates_*` convention; extracted the rate/change math out of
`ExchangeRateViewData.build()` into a standalone `CurrencyRateChange` domain value object
(`CurrencyRateChange.fromQuotes`/`fromResponses`, `RateTrend` enum) so the presentation
layer's `ExchangeRateViewData.fromChange()` only formats, it doesn't compute; replaced the
loading widget's bare `CircularProgressIndicator` with a `shimmer`-based skeleton list
matching the real item's layout; locked `AndroidManifest.xml`
(`android:screenOrientation="portrait"`) and `Info.plist`
(`UISupportedInterfaceOrientations`) to portrait-only.

**Decision:** Accepted, with one leftover flagged: the rename left both
`exchange_rate_list_item.dart` (old singular name, unused) and
`exchange_rates_list_item.dart` (new plural name, actually imported) present in
`widgets/` — worth deleting the dead duplicate in a follow-up pass.

**Why:** Consistent plural naming across the feature avoids the kind of singular/plural
drift that already needed a cleanup pass here; centralizing the rate/change math in one
domain object (rather than duplicating the inversion/color logic in the view-data class)
keeps `ExchangeRateViewData` a pure formatter, matching the "no formatting/business logic
mixed together" rule from the original plan (Entry 11).

---

## Entry 13 — 2026-07-22

**Prompt:** "formant this part wiht meaningful message for each error extension
DataSourceExtension on ResponseType {...}" — pasted the `getFailure()` switch statement,
whose cases mostly returned placeholder strings (`"formatException"`, `"httpException"`,
`"socketException"`) unrelated to the actual case, several marked `// not used`.

**Model returned:** Replaced every placeholder string with a specific, user-facing message
for that case (e.g. `noContent` → "No data was returned by the server", `unauthorised` →
"Session expired, please log in again", `serviceUnavailable`/`serviceUnavailable2` →
"Service is currently unavailable, please try again later"), and reformatted each `case` to
a single-line `return` for consistency.

**Decision:** Accepted.

**Why:** The original strings were copy-pasted exception-type names rather than messages,
so they gave the wrong `Failure.message` for cases like `noContent`/`badRequest` — direct,
unambiguous fix with no design tradeoff to weigh.

---

</details>

<details>
<summary><strong>Currency Detail</strong> (Entries 14–19)</summary>

---

## Entry 14 — 2026-07-22

**Prompt:** "currency details feature will use the same usecase of exchange rate, so should i
use it directly from exchange rates or are there any alternatives"

**Model returned:** Recommended calling the existing `GetExchangeRatesUseCase` directly from
the new `CurrencyDetailBloc` rather than introducing a new repository/data source/use-case
wrapper. Laid out the alternatives and why they're worse: reusing the repository directly
skips the domain boundary, reusing the data source reaches into another feature's internals,
and duplicating the network call causes divergence — whereas the use case is the correct,
intended sharing boundary. Noted this matches the `currency_detail.md` plan (no `data/` layer
of its own; only the 7-day chart needs fetching) and the as-built `ExchangeRateBloc`
precedent, which already combines its own multi-call fetch inside the bloc.

**Decision:** Accepted.

**Why:** Of all the ways to reuse the data path, sharing at the use-case layer is the one that
respects Clean Architecture's dependency direction — better than duplicating logic or reaching
past the domain boundary into another feature's data layer.

---

## Entry 15 — 2026-07-22

**Prompt:** "continue Architecture / folder structure for currency details" — asked to
implement the folder structure laid out in the `currency_detail.md` plan doc.

**Model returned:** Built the full `currency_detail/` feature per the plan:
`presentation/bloc/currency_detail_bloc.dart` (fires 7 calls via `Future.wait` — 6 historical
days + one `null`/latest call so the newest point matches the header's current rate exactly —
folds the `Either` results into a list with first-failure-short-circuits, inverts each raw
`egp[code]` quote via `1 / raw`, skips null/zero days, emits `List<CurrencyHistoryPoint>`);
the page (`StatelessWidget` rendering the top section straight from nav args, no bloc
dependency); and widgets `currency_detail_header`, `current_rate_card`, `stat_card` +
`stat_card_grid` (one data-driven tile fed 4×), `currency_history_chart_card` (owns its
`BlocBuilder` and the loading/error/success branching), `currency_history_chart` (`fl_chart`
`LineChart` with `minY`/`maxY` computed from the actual fetched range, line colored by
`weekTrend`), `currency_history_chart_loading` (shimmer, not a spinner),
`currency_history_chart_error`, and `inverted_rate_info_banner`. Wired
`RouteName.currencyDetail` in `app_router.dart` (extracting `CurrencyDetailArgs`, dispatching
`GetCurrencyHistoryEvent`) and hand-added `CurrencyDetailBloc` to the manually maintained
`service_locator.config.dart`, depending only on the already-registered
`GetExchangeRatesUseCase`.

**Decision:** Accepted. Verified with `flutter analyze` (no new issues) and
`flutter build apk --debug` (built clean).

**Why:** Followed the pre-written plan doc rather than improvising, matching the project's
practice of speccing before coding (Entries 3, 11); the shimmer loading and computed axis
range are direct carry-overs of decisions already made for the list screen (Entry 12) and the
mockup's broken axis labels (Entry 1).

---


## Entry 17 — 2026-07-22

**Prompt:** "why did we make factory CurrencyDetailArgs.fromViewData... i think we don't need
it and access the data directly from constructor"

**Model returned:** Agreed and removed the `fromViewData` factory, mapping the fields inline at
the single call site in `exchange_rates_list_item.dart` (which already holds the
`ExchangeRateViewData` item and imports both types). Removing the factory also dropped the
`ExchangeRateViewData` import from `CurrencyDetailArgs`, leaving it a plain data holder whose
only dependency is the `RateTrend` domain enum.

**Decision:** Accepted.

**Why:** The factory had one caller (YAGNI) and was the sole thing coupling the args class to a
presentation view model — removing it both cut indirection and finished the layering cleanup
started in Entry 16.

---


## Entry 18 — 2026-07-22

**Prompt:** "i changed the model to opus to ask =>does my current arch is a good approach as i used the usecase from exchange rate
feature directly"

**Model returned:** Reviewed the architecture (no code change). Assessed reusing
`GetExchangeRatesUseCase` directly as the correct sharing boundary, but flagged the real
weakness as *where the logic lives* — the 7-call orchestration, `1/raw` inversion, and
null/zero filtering sit in the bloc rather than a domain object, unlike the list feature's
`CurrencyRateChange`. Noted this is nonetheless consistent with the as-built `ExchangeRateBloc`
(which also combines its fetch inline), and named the cross-feature coupling on
`exchange_rates`' entities as the trade-off. Suggested — as optional, not required — extracting
a `GetCurrencyHistoryUseCase` into `currency_detail/domain/` to move that logic out of the
bloc.

**Decision:** Accepted the current approach; extraction left as an optional follow-up.

**Why:** For a two-screen app, matching the existing inline-combine precedent has more value
than a purer-but-inconsistent wrapper; surfaced the honest trade-off rather than either
rubber-stamping or over-engineering it.

---

</details>

<details>
<summary><strong>Offline Caching &amp; Polish</strong> (Entries 19–21)</summary>

---

## Entry 19 — 2026-07-22

*(Entries 19–21 reconstructed from commit history/diffs and `offline_cache.md`, not from a
live transcript — same convention as Entries 10–12.)*

**Prompt (reconstructed):** Asked Claude to plan and implement "Module 3" — the offline caching
layer that makes the app's headline offline feature real: persist the last fetched rates locally,
serve them when the network is down, show when the data was last updated, and auto-refresh when
connectivity returns. Same spec-before-code discipline as the earlier modules.

**Model returned:** Wrote `offline_cache.md` (requirements→approach table, data-flow states, the
"cache lives in the repository, not the bloc" rule) then implemented it: a Hive-backed
`ExchangeRateLocalDataSource` with **write-through** on every successful fetch and **read-through**
fallback on failure, wired into `ExchangeRateRepositoryImpl` as the single insertion point so
neither bloc knows about Hive. Added an `ExchangeRatesResult` domain wrapper ({data, timestamp,
isFromCache}) so the bloc can surface the *real* fetch time instead of blindly setting
`lastUpdated = DateTime.now()`. Added a `ConnectivityService` (`connectivity_plus`) that both blocs
subscribe to — a `ConnectivityChangedEvent` flips an `isOffline` flag and re-dispatches the fetch
on an offline→online transition. Surfaced offline state in the UI: `UpdateStatusRow`'s dot goes
amber with "Offline · Updated &lt;time&gt;", and a new `DetailOfflineIndicator` shows on the detail
screen. Because both screens share `GetExchangeRatesUseCase`, caching at the repository
transparently made the 7-day chart work offline too.

**Decision:** Accepted.

**Why:** Two deliberate calls stand out. Caching at the repository (not the bloc) keeps data
concerns in the data layer and gets the detail chart's offline support "for free" via the shared
use case (Entry 14). Serializing the response model as a `jsonEncode`d String envelope instead of
`hive_generator`/`TypeAdapter`s sidesteps both Hive's dynamic-map read typing *and* this repo's
non-working build_runner pipeline — a pragmatic fit for the project's hand-maintained DI
(`service_locator.config.dart`).

---

## Entry 20 — 2026-07-22

**Prompt (reconstructed):** Asked Claude to extend the same offline behavior to the currency-detail
history and tidy up the caching bootstrap, plus a round of small UI polish on how rate direction is
shown.

**Model returned:** Added a `CurrencyHistoryLocalDataSource` and a `HiveStorage` helper that
centralizes box names and opening (`exchange_rates_cache`, `currency_history_cache`, `app_settings`)
behind one `HiveStorage.init()`, replacing the inline `Hive.openBox` calls in `main.dart`; the
`app_settings` box also persists an `onboarding_seen` flag. UI polish: replaced the textual `+`/`-`
sign convention on the detail screen's Daily Change / Change % stat cards and the list item's change
label with a directional **trend arrow** (`arrow_upward`/`arrow_downward`, none when unchanged) plus
the absolute value — a new `icon` parameter on `StatCard` and a `trendIcon` getter on
`ExchangeRateViewData`, both driven off the existing `RateTrend` enum.

**Decision:** Accepted.

**Why:** Centralizing box management in `HiveStorage` keeps the growing set of caches (and the new
settings box) out of `main.dart` as more of them appear. The trend-arrow treatment reuses the
`RateTrend` enum that already drives the color semantics (Entry 11) rather than re-deriving
direction from the sign of the number, keeping a single source of truth for "which way did it move".

---

## Entry 21 — 2026-07-22

**Prompt (reconstructed):** Refined the repository's offline path — guard the request so it never
fires while offline, and remove the duplicated read-through fallback.

**Model returned:** Added an early `connectivityService.isConnected()` check at the top of
`getExchangeRates` that short-circuits to cache (with a "No internet connection" message on a miss)
before touching the network, so a known-offline call doesn't wait on a doomed request/timeout. Folded
the two identical cache-fallback blocks (the offline guard and the `catch`) into one `_cachedOr`
helper returning `Right(cache, cachedAt, isFromCache: true)` on a hit and `Left(message)` on a miss.

**Decision:** Accepted (working-tree change, not yet committed at time of writing).

**Why:** The original code only served cache *after* a failed request; checking connectivity up front
avoids a pointless network attempt when we already know we're offline, and extracting `_cachedOr`
removes the copy-pasted fallback so the read-through logic lives in one place — the same
consolidation instinct applied to the view-data/domain math in Entry 12.

---

</details>

<!-- Add new sections/entries above this line as the project progresses. -->
