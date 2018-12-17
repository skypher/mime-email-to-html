#!/bin/sh
#cat /dev/stdin > "$HOME/spiritus/foo.txt"

set -x

SCRIPT_HOME=$(pwd)/./$(dirname "$0")
OUTROOT="$SCRIPT_HOME/../out_html"
OUTDIR="$OUTROOT/$(date -Iseconds)"
RAWFILE="$OUTDIR/raw.eml"

mkdir -p "$OUTDIR"
cd "$OUTDIR"

cp /dev/stdin "$RAWFILE"

TITLE=$(grep -E \^Subject: "$RAWFILE" | cut -d\[ -f3 | sed -e 's/[[:space:]]*$//')

RAWFILE_TITLED='['"$TITLE.eml"
mv "$RAWFILE" "$RAWFILE_TITLED"

HTMLFILE=$("$SCRIPT_HOME"/replace-inline-images.sh "$RAWFILE_TITLED" "$OUTDIR" | grep HTMLFILE | cut -d: -f2-)
HTMLFILE_TITLED="$OUTDIR"/'['"$TITLE.html"
# TODO assert HTMLFILE captured
"$SCRIPT_HOME"/sanitize-yahoo-html.py "$HTMLFILE" "$HTMLFILE_TITLED"
# TODO check if tree util installed
cd "$OUTROOT"
find . -type f -exec chmod go+r '{}' \;
tar cfj archive.tar.bz2 * --exclude=\*.eml --exclude=\*.tar.bz2
tree -Dtrfh -H . -I *.eml -P \*.html\|archive.tar.bz2 -T 'Spiritus Angel Messages' > index.html
cp "$SCRIPT_HOME"/style.css "$OUTROOT" -v
