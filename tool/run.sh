#!/bin/bash
# Derle + 8 ekran görüntüsü + karşılaştırma
set -e
cd "$(dirname "$0")/.."
export PATH=/opt/flutter/bin:$PATH
flutter build web --release --no-web-resources-cdn >/dev/null 2>&1
pgrep -f "http.server 8765" >/dev/null || (python3 -m http.server 8765 -d build/web >/dev/null 2>&1 &)
sleep 1
SCROLLS='{"2":759,"3":1539,"7":668,"8":1184}' node tool/shots.js "$1"
python3 tool/compare.py ${1//,/ }
