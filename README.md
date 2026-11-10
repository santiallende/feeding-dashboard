# Feeding dashboard

A single-page dashboard for exploring Huckleberry feeding exports, built for sharing with providers.

- **Published page:** https://santiallende.github.io/feeding-dashboard/ (passphrase-protected)
- **Local copy:** double-click `index.html` in this folder (no passphrase needed locally)

## Publish the latest data (one command)

1. Export the CSV from Huckleberry. It lands in `~/Downloads` or wherever you save it; putting it in this folder also works.
2. If you added or edited events in the dashboard, click **Export JSON** there (it saves `events.json` to Downloads).
3. Run:

   ```
   ./publish.sh
   ```

The script brings in the newest Huckleberry CSV (from this folder or Downloads), picks up a newer `events.json` if you exported one, removes older exports, encrypts everything into `data.enc.js` using the passphrase in `.passphrase`, commits, and pushes. GitHub Pages redeploys in a minute or two.

### What leaves your Mac

Only `index.html`, the D3 and WHO reference files, and `data.enc.js` are in the repository. `data.enc.js` is the CSV and events encrypted with AES-256-GCM (key derived from the passphrase with PBKDF2, 300k iterations). The raw CSV, `events.json`, `profile.json`, the plain `data.js` and `.passphrase` are git-ignored and never uploaded.

### Passphrase

It lives in `.passphrase` (one line). Give it to providers by voice or text, not on the page. To change it, edit the file and run `./publish.sh` again; the old passphrase stops working as soon as the site redeploys. Viewers enter it once per browser tab; "Lock" in the toolbar forgets it.

## Events (famotidine, daycare, illness, …)

Add them in the "Events" card. They are drawn on every chart, compared before/during/after, and illness events can be excluded from all averages with the "Exclude illness days" switch.

Events you add are saved in your browser. **Export JSON** then `./publish.sh` is what puts them on the published page; providers see the published list. If your browser's list drifts from the published one, "Use published events" resets it.

## What the sections answer

- **Hero chart (top):** intake per body weight as kcal/kg/day (default), ml/kg/day or oz/lb/day, against the targets from the nutrition note in `profile.json` (estimated needs and prescribed intake). Formula calories follow the kcal/oz schedule in `profile.json` (standard mix, fortified mix and the date it started). Weigh-in markers, age labels and event bands included. All of these numbers are editable in Settings.
- **Weight for age:** every weigh-in (home from Huckleberry, clinic from Settings) against the WHO girls weight-for-age standard, with her percentile over time alongside. Hover any point for percentile, z-score and a plain-language reading.
- **KPI tiles:** last 7 full days vs the 7 before.
- **Intake:** ounces per day, week or month, with the trailing 7-day average on the daily view.
- **How she's eating:** feeds/day, oz per feed, largest feed, longest stretch, sleep, poops.
- **When she eats:** hour-of-day heatmap by week.
- **Bottle size vs. time to next feed:** whether a bigger bottle buys a longer stretch.
- **Hunger drive:** lead-lag analysis. Each day is compared with its neighbours' average; the correlation between today's and tomorrow's deviation is tested against a shuffled-days baseline, because detrending alone creates a spurious negative correlation.
- **Events:** before/during/after comparison for each event, with a Welch t-test on the daily totals.

The hunger-drive and events cards each have a collapsible "How to read this section" glossary, and every tile, bar, dot and dumbbell row explains what its numbers mean when hovered.

## Data handling notes

- Name, birth date, the formula kcal/oz schedule, nutrition-note targets and clinic weigh-ins live in `profile.json` (git-ignored, bundled into the encrypted data) and can be overridden per browser in Settings. Nothing personal is in `index.html` or this repository. 
- "All" starts on the first day fully on measured bottle feeds (nursing has no ounces).
- The last day of the export is treated as partial and left out of averages.
- Single bottles over 10 oz are treated as typos and not counted (listed in the footer). Fix them in Huckleberry and re-export.
- Sleep and diaper figures only cover days on which they were logged.
- The ◐ button toggles light/dark; printing always uses the light theme.

## Files

- `index.html` – the dashboard (all logic inside)
- `data.enc.js` – encrypted bundle, the only data file that is published
- `data.js` – plain bundle for local use (generated, git-ignored)
- `vendor/d3.v7.min.js` – charting library, vendored so it works offline
- `vendor/who_wfa_girls.js` – WHO weight-for-age LMS table for girls (days 0–731), from the WHO expanded tables
- `build_data.py` – CSV + events → `data.js` and `data.enc.js`
- `publish.sh` – the one-command update described above
- `events.json`, `profile.json`, `*.csv`, `.passphrase` – local only, never committed
