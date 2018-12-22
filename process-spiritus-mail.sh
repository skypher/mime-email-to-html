#!/bin/bash

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

    RAWFILE_TITLED='['"$TITLE.eml"
    cp "$RAWFILE" "$RAWFILE_TITLED"

    HTMLFILE=$("$SCRIPT_HOME"/replace-inline-images.sh "$RAWFILE_TITLED" "$OUTDIR" | grep HTMLFILE | cut -d: -f2-)
    HTMLFILE_TITLED="$OUTDIR"/'['"$TITLE.html"
    # TODO assert HTMLFILE captured
    "$SCRIPT_HOME"/sanitize-yahoo-html.py "$HTMLFILE" "$HTMLFILE_TITLED"
    # TODO check if tree util installed
    cd "$OUTROOT"
    find . -type f -exec chmod go+r '{}' \;
    tar cfj archive.tar.bz2 * --exclude=\*.eml --exclude=\*.tar.bz2
    tree -Dtrfh -H . -I \*.eml -P \*.html\|archive.tar.bz2 -T 'Spiritus Angel Messages' > index.html
    cp "$SCRIPT_HOME"/style.css "$OUTROOT" -v

    popd
done
