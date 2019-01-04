#!/bin/bash

# check tool dependencies
# ripmime and python3 are needed in the other scripts; check them
# here as well to fail early.
set -e
which tree zip python2 python3 tr Xvfb wkhtmltopdf ripmime
python3 -c 'import bs4'
set +e

set -x

umask 022

SCRIPT_HOME=$(dirname $(readlink -f "$0"))
OUTROOT="$SCRIPT_HOME/../out_html"
INDIR="$SCRIPT_HOME/../raw/"

RAWFILES=$(find "$INDIR" -type f)

Xvfb :99 &
XVFB_PID=$!

function cleanup {
  kill -TERM $XVFB_PID 
}

trap cleanup EXIT

IFS=$'\n'
for RAWFILE in $RAWFILES; do
    RAWFILE_CTIME=$(stat -c\%Y "$RAWFILE")
    OUTDIR="$OUTROOT/$(date -Iseconds -d\@"$RAWFILE_CTIME")"
    #if [ -d "$OUTROOT" ]; then continue; fi # already processed, skip
    mkdir -p "$OUTDIR"
    pushd "$OUTDIR"

    # sed multi-line expression are a PITA (and email headers don't give a fuck about that :S )
    # using python2 because python3 exhibits decoding issues. to be fixed as necessary later.
    SANITIZED_MAIL_HEADERS=$(cat "$RAWFILE" | python2 -c 'import sys; import re; sys.stdout.write(re.sub(r"\n(\s+)", " ", sys.stdin.read()))' | head -n100)
    TITLE=$(echo "$SANITIZED_MAIL_HEADERS" | grep -E \^Subject: | cut -d\[ -f3 | head -n1 | sed -e 's/[[:space:]]*$//')

    RAWFILENAME="[$TITLE.eml"
    HTMLFILENAME=$(echo "$TITLE.html" | tr -s ' ,[]{}' '-')
    cp "$RAWFILE" "$RAWFILENAME"

    HTMLFILE=$("$SCRIPT_HOME"/replace-inline-images.sh "$RAWFILENAME" "$OUTDIR" | grep HTMLFILE | cut -d: -f2-)
    HTMLFILE_WITHPATH="$OUTDIR"/"$HTMLFILENAME"
    # TODO assert HTMLFILE captured
    "$SCRIPT_HOME"/sanitize-yahoo-html.py "$HTMLFILE" "$HTMLFILE_WITHPATH" "$(echo "$TITLE" | sed -e 's/]/: /g' | tr -s ' ' ' ')"
    DISPLAY=:99 wkhtmltopdf "$HTMLFILE_WITHPATH" "$HTMLFILE_WITHPATH".pdf
    rm -f {text,multipart}-* &

    cd "$OUTROOT"
    find . -type f -exec chmod go+r '{}' \;

    popd
done

cd "$OUTROOT"
zip archive.zip -x\*.eml -ruo 20* index.html style*.css assets
"$SCRIPT_HOME"/mkindex.sh "$OUTROOT"
cp -av "$SCRIPT_HOME"/assets/ "$OUTROOT"
cp -av "$SCRIPT_HOME"/assets/favicon/* "$OUTROOT"
