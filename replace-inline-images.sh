#!/bin/sh

set -x

# check tool dependencies
set -e
which ripmime
python3 -c 'import bs4'
set +e

if [ -z "$1" -o -z "$2" ]; then
  echo Usage: $0 mimefile outdir
  exit
fi

MIMEFILE="$1"
OUTDIR="$2"

mkdir -p "$OUTDIR"

HTMLFILE=$(ripmime --overwrite -i "$MIMEFILE" -v --name-by-type | grep html | cut -d\= -f2)
HTMLFILE_NEWNAME=$(echo "$MIMEFILE" | sed -r 's/\s+\[[0-9]+ Attachments\]//g' | sed 's/.eml//g')

CIDS=$(/bin/grep -i Content-ID: "$MIMEFILE" | cut -d\< -f2 | cut -d\> -f1)
echo CIDS:$CIDS
FILENAMES=$(/bin/grep -i filename\= "$MIMEFILE" | cut -d\" -f2)
echo FILES:$FILENAMES

TMP1=$(mktemp)
TMP2=$(mktemp)
echo "$CIDS" > "$TMP1"
echo "$FILENAMES" > "$TMP2"
for f in $FILENAMES; do
  mv "$f" "$OUTDIR"
done
MERGED=$(paste -d/ "$TMP1" "$TMP2")
rm -f "$TMP1" "$TMP2"

echo MERGED:$MERGED

for i in $MERGED; do
  SUB="s/cid:$i/g"
  sed -i "$SUB" "$HTMLFILE"
done

echo HTMLFILE:"$HTMLFILE"
