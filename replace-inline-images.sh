#!/bin/sh

if [ -z "$1" ]; then
  echo Usage: $0 mimefile
  exit
fi

mkdir -p ./processed

MIMEFILE="$1"

set -e
set -x

HTMLFILE=$(ripmime -i "$MIMEFILE" -v --name-by-type | grep html | cut -d\= -f2)
HTMLFILE_NEWNAME=$(echo "$MIMEFILE" | sed -r 's/\s+\[[0-9]+ Attachments\]//g' | sed 's/.eml//g')

CIDS=$(/bin/grep -i Content-ID: "$MIMEFILE" | cut -d\< -f2 | cut -d\> -f1)
echo $CIDS
FILENAMES=$(/bin/grep -i filename\= "$MIMEFILE" | cut -d\" -f2)
echo $FILENAMES

TMP1=$(mktemp)
TMP2=$(mktemp)
echo "$CIDS" > "$TMP1"
echo "$FILENAMES" > "$TMP2"
for f in $FILENAMES; do
  mv "$f" processed
done
MERGED=$(paste -d/ "$TMP1" "$TMP2")

echo $MERGED

for i in $MERGED; do
  SUB="s/cid:$i/g"
  sed -i "$SUB" "$HTMLFILE"
done

./sanitize-yahoo-html.py "$HTMLFILE" "./processed/$HTMLFILE_NEWNAME.html"

