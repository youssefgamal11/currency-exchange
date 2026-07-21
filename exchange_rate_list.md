# Exchange Rate List Screen — UI Implementation

## Context

With the onboarding screen's design-token infrastructure in place (`AppColors`, `AppTextStyle`,
`ImgPath`, bundled fonts/SVG flags), this builds the app's second screen: a live-feeling list of
EGP exchange rates against USD, EUR, GBP, SAR, and JPY. Same scope discipline as onboarding —
UI only, hardcoded mock data, no Bloc/state management, no real navigation wiring (the route is
registered for consistency but nothing triggers it yet; `onBoarding` stays the app's entry point).

## Screen structure (from the approved screenshot)

1. Header — "Exchange Rates" title + circular refresh icon button.
2. Status line — green "live" dot + "Updated 05:27 PM".
3. Base currency selector — bordered pill (Egypt flag + "Egyptian Pound (EGP)" in accent gold)
   with a "Base currency" label beside it.
4. Scrollable list of rate cards, one per currency, each showing: circular flag avatar, code +
   full name, a small trend sparkline, the rate ("1 USD = 51.09") with the value in accent gold,
   a colored daily change line with an up/down arrow, and a trailing chevron.

## File-by-file changes

### Shared widget promoted
- `lib/features/_shared/widgets/mini_sparkline.dart` — moved here from the onboarding feature
  (was `lib/features/onBoarding/presenation/widgets/mini_sparkline.dart`), since the same tiny
  `CustomPainter` line chart is needed by both screens. `mini_currency_row.dart`'s import was
  updated to point at the shared location; no other onboarding files changed.

### New: `lib/features/exchange_rate_list/presentation/`
- `models/exchange_rate.dart` — plain `ExchangeRate` data class (code, name, flagAsset, rate,
  changeLabel, isPositive, sparklinePoints). Rate/change values are pre-formatted strings, same
  "no formatting logic in widgets" approach as onboarding's mock data.
- `widgets/exchange_rate_header.dart` — title + refresh button row.
- `widgets/update_status_row.dart` — green dot + "Updated ..." status line.
- `widgets/base_currency_selector.dart` — the EGP base-currency pill.
- `widgets/exchange_rate_list_item.dart` — one rate card: flag avatar, code/name, sparkline,
  rate + change, chevron.
- `pages/exchange_rate_list_page.dart` — assembles the above with `ListView.separated` and a
  hardcoded 5-entry mock rate list (USD/EUR/GBP/SAR/JPY, matching the screenshot's values).

### Routing
- `lib/core /routing/route_name.dart` — added `RouteName.exchangeRateList`.
- `lib/core /routing/app_router.dart` — added the matching `MaterialPageRoute` case.
- `main.dart`'s `initialRoute` left untouched (still onboarding).

## Design tokens used (no changes needed)
All colors/text styles/flag paths reused as-is from `AppColors`, `AppTextStyle`, `ImgPath` —
see `onboarding.md` for the full token reference. No new pubspec dependencies or assets.
