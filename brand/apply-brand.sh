#!/usr/bin/env bash
# Applies one brand (brand/<name>/) to a RustDesk source tree. Run from the source root:
#   bash brand/apply-brand.sh rickburn
set -euo pipefail
B="brand/$1"
[ -f "$B/brand.json" ] || { echo "No brand $1"; exit 1; }
source "$B/brand.env"
cp "$B/brand.json" res/brand.json
cp -R "$B/files/." ./
# Colours (flutter/lib/common.dart MyTheme)
sed -i.bak -e "s/static const Color accent = Color(0xFF0071FF)/static const Color accent = Color($ACCENT)/" \
  -e "s/static const Color accent50 = Color(0x770071FF)/static const Color accent50 = Color(0x77${ACCENT:4})/" \
  -e "s/static const Color accent80 = Color(0xAA0071FF)/static const Color accent80 = Color(0xAA${ACCENT:4})/" \
  -e "s/static const Color idColor = Color(0xFF00B6F0)/static const Color idColor = Color($ID_COLOUR)/" \
  -e "s/static const Color button = Color(0xFF2C8CFF)/static const Color button = Color($BUTTON)/" flutter/lib/common.dart
# Banner cards (install / permissions): brand gradient instead of RustDesk's pink
if [ -n "${CARD_FROM:-}" ]; then
  sed -i.bak -e "s/Color.fromARGB(255, 226, 66, 188)/Color($CARD_FROM)/" -e "s/Color.fromARGB(255, 244, 114, 124)/Color($CARD_TO)/" flutter/lib/desktop/pages/desktop_home_page.dart
  rm -f flutter/lib/desktop/pages/desktop_home_page.dart.bak
fi
# Names shown in the program's file properties
sed -i.bak -e "s/\"RustDesk Remote Desktop\"/\"$APP_NAME\"/" -e "s/VALUE \"ProductName\", \"RustDesk\"/VALUE \"ProductName\", \"$APP_NAME\"/" flutter/windows/runner/Runner.rc
sed -i.bak -e "s/^ProductName = \"RustDesk\"/ProductName = \"$APP_NAME\"/" -e "s/^FileDescription = \"RustDesk Remote Desktop\"/FileDescription = \"$APP_NAME\"/" libs/portable/Cargo.toml
rm -f flutter/lib/common.dart.bak flutter/windows/runner/Runner.rc.bak libs/portable/Cargo.toml.bak
grep -c "$ACCENT" flutter/lib/common.dart
echo "Applied brand $1 ($APP_NAME)"
