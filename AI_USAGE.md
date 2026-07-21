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

<!-- Add new entries above this line as the project progresses. -->
