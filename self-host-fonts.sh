#!/usr/bin/env bash
# ORUNEVA — move the two typefaces off Google's servers and onto your own.
#
# Why: as long as the page loads fonts from fonts.googleapis.com, every visitor's
# browser sends their IP address to Google. A German court (LG München I,
# 3 O 17493/20, 20 Jan 2022) awarded damages against a site operator for exactly
# that. Self-hosting removes the third-party request entirely — after this the
# site contacts nothing outside your own domain, which is why it needs no
# cookie banner.
#
# Run it once, from inside this folder, then redeploy:
#     chmod +x self-host-fonts.sh && ./self-host-fonts.sh
#
# Requires curl. Takes about ten seconds.

set -euo pipefail
cd "$(dirname "$0")"
mkdir -p fonts

UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
API='https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@62..125,300..800&family=Azeret+Mono:wght@300;400;500&display=swap'

echo "→ fetching the font stylesheet"
curl -sSL -A "$UA" "$API" -o fonts/fonts.css

echo "→ downloading the font files"
grep -o 'https://fonts.gstatic.com/[^)]*' fonts/fonts.css | sort -u | while read -r url; do
  file="$(basename "$url")"
  curl -sSL -o "fonts/$file" "$url"
  echo "   $file"
  # point the stylesheet at the local copy
  python3 - "$url" "$file" <<'PY'
import sys, pathlib
url, file = sys.argv[1], sys.argv[2]
p = pathlib.Path("fonts/fonts.css")
p.write_text(p.read_text().replace(url, file))
PY
done

echo "→ rewriting index.html"
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("index.html")
html = p.read_text()
html = re.sub(r'\s*<link rel="preconnect" href="https://fonts\.(googleapis|gstatic)\.com"[^>]*>', '', html)
html = re.sub(r'<link rel="stylesheet" href="https://fonts\.googleapis\.com/[^"]*">',
              '<link rel="stylesheet" href="/fonts/fonts.css">', html)
p.write_text(html)
PY

echo "→ tightening the Content-Security-Policy"
python3 - <<'PY'
import pathlib
p = pathlib.Path("_headers")
t = p.read_text()
t = t.replace(" https://fonts.googleapis.com", "").replace(" https://fonts.gstatic.com", "")
p.write_text(t)
PY

echo
echo "Done. The site now serves its own fonts and makes no third-party request."
echo "Next: in the cookie page, delete the section headed 'The one external request'."
