#!/bin/bash
# One command to publish the latest data:
#   1. finds the newest Huckleberry CSV in this folder or ~/Downloads and brings it here
#   2. picks up a newer events.json from ~/Downloads if you exported one from the dashboard
#   3. encrypts everything into data.enc.js with the passphrase in .passphrase
#   4. commits and pushes, which redeploys the GitHub Pages site
set -euo pipefail
cd "$(dirname "$0")"

is_huckleberry() { head -1 "$1" 2>/dev/null | grep -q '"Type","Start"'; }

# --- 1. newest CSV ---------------------------------------------------------
newest=""
for f in $(ls -t ./*.csv ~/Downloads/*.csv 2>/dev/null); do
  if is_huckleberry "$f"; then newest="$f"; break; fi
done
if [ -z "$newest" ]; then echo "No Huckleberry CSV found in this folder or ~/Downloads."; exit 1; fi
case "$newest" in
  ./*) ;;
  *) echo "Bringing in $(basename "$newest") from Downloads"; cp "$newest" ./ ; newest="./$(basename "$newest")" ;;
esac
for f in ./*.csv; do
  if [ "$f" != "$newest" ] && is_huckleberry "$f"; then echo "Removing older export $(basename "$f")"; rm "$f"; fi
done

# --- 2. newer events.json from Downloads -----------------------------------
latest_events=$(ls -t ~/Downloads/events*.json 2>/dev/null | head -1 || true)
if [ -n "$latest_events" ]; then
  if [ ! -f ./events.json ] || [ "$latest_events" -nt ./events.json ]; then
    if head -c 1 "$latest_events" | grep -q '\['; then echo "Using newer events from $(basename "$latest_events")"; cp "$latest_events" ./events.json; fi
  fi
fi

# --- 3. passphrase + build -------------------------------------------------
if [ ! -s .passphrase ]; then
  echo "No .passphrase file yet. Type the passphrase providers will use (it is saved in .passphrase, which is never committed):"
  read -r -s pass; echo
  printf '%s' "$pass" > .passphrase
fi
python3 build_data.py "$newest"

# --- 4. commit + push ------------------------------------------------------
through=$(python3 -c "import csv,sys; print(max(r['Start'] for r in csv.DictReader(open(sys.argv[1], encoding='utf-8-sig')))[:10])" "$newest")
git add -A
if git diff --cached --quiet; then echo "Nothing new to publish (data through $through already live)."; exit 0; fi
git commit -q -m "Update data through $through"
git push -q
echo "Published data through $through. The site updates within a minute or two."
