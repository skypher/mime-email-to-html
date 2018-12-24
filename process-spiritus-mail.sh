#!/bin/bash

# check tool dependencies
set -e
which tree zip ripmime python3 tr
set +e

set -x

umask 022

SCRIPT_HOME=$(dirname $(readlink -f "$0"))
OUTROOT="$SCRIPT_HOME/../out_html"
INDIR="$SCRIPT_HOME/../raw/"

RAWFILES=$(find "$INDIR" -type f)

IFS=$'\n'
for RAWFILE in $RAWFILES; do

    RAWFILE_CTIME=$(stat -c\%Y "$RAWFILE")
    OUTDIR="$OUTROOT/$(date -Iseconds -d\@"$RAWFILE_CTIME")"
    mkdir -p "$OUTDIR"
    pushd "$OUTDIR"

    TITLE=$(grep -E \^Subject: "$RAWFILE" | cut -d\[ -f3 | sed -e 's/[[:space:]]*$//')

    RAWFILENAME="$TITLE.eml"
    HTMLFILENAME=$(echo "$TITLE.html" | tr -s ' ,[]{}' '-')
    cp "$RAWFILE" "$RAWFILENAME"

    HTMLFILE=$("$SCRIPT_HOME"/replace-inline-images.sh "$RAWFILENAME" "$OUTDIR" | grep HTMLFILE | cut -d: -f2-)
    HTMLFILE_WITHPATH="$OUTDIR"/"$HTMLFILENAME"
    # TODO assert HTMLFILE captured
    "$SCRIPT_HOME"/sanitize-yahoo-html.py "$HTMLFILE" "$HTMLFILE_WITHPATH" "$(echo "$TITLE" | sed -e 's/]/: /g' | tr -s ' ' ' ')"
    cd "$OUTROOT"
    find . -type f -exec chmod go+r '{}' \;

    popd
done

cd "$OUTROOT"
zip archive.zip -x\*.eml -rf *
tree -Dtrfh -H . -I \*.eml -P \*.html\|archive.tar.bz2 -T 'Spiritus Angel Messages' > index.html
cp "$SCRIPT_HOME"/style.css "$OUTROOT" -v
