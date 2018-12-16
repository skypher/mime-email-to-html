#!/bin/sh
#cat /dev/stdin > "$HOME/spiritus/foo.txt"

set -x

SCRIPT_HOME=$(pwd)/./$(dirname "$0")
OUTDIR="$SCRIPT_HOME/../out_html/"$(date -Iseconds)
RAWFILE="$OUTDIR/raw.eml"

mkdir -p "$OUTDIR"

cp /dev/stdin "$RAWFILE"

cd "$OUTDIR"
HTMLFILE=$("$SCRIPT_HOME"/replace-inline-images.sh "$RAWFILE" "$OUTDIR" | grep HTMLFILE | cut -d: -f2-)
# TODO assert HTMLFILE captured
"$SCRIPT_HOME"/sanitize-yahoo-html.py "$HTMLFILE" "$OUTDIR/$HTMLFILE.html"
