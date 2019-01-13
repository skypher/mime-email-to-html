#!/bin/bash

set -x
set -e

which find sed grep stat # dep sanity check

test -d "$1"

cd "$1"

OUTFILE="index.html"
LISTFILE="htmlfiles.txt"

cat <<EOF > "$OUTFILE"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>

    <!-- *** Bootstrap *** -->
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

    <!-- JQuery -->
    <script src="https://code.jquery.com/jquery-3.3.1.min.js"
      integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
      crossorigin="anonymous"></script>

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    <!-- favicon -->
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-icon-57x57.png">
    <link rel="apple-touch-icon" sizes="60x60" href="/apple-icon-60x60.png">
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-icon-72x72.png">
    <link rel="apple-touch-icon" sizes="76x76" href="/apple-icon-76x76.png">
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-icon-114x114.png">
    <link rel="apple-touch-icon" sizes="120x120" href="/apple-icon-120x120.png">
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-icon-144x144.png">
    <link rel="apple-touch-icon" sizes="152x152" href="/apple-icon-152x152.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-icon-180x180.png">
    <link rel="icon" type="image/png" sizes="192x192"  href="/android-icon-192x192.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="96x96" href="/favicon-96x96.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="manifest" href="/manifest.json">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="msapplication-TileImage" content="/ms-icon-144x144.png">
    <meta name="theme-color" content="#ffffff">

    <!-- *** site-local *** -->
    <title>Hermetic Angel Messages</title>
    <link rel="stylesheet" href="assets/style-index.css" type="text/css" />
</head> 
<body>
EOF

find . -type f -iname \*angel\*.html | sort -r > "$LISTFILE"

cat <<EOF >> "$OUTFILE"
<div class="row">
    <div class="col-lg-3"></div>
    <div class="col-lg-6">
        <h1>
        Hermetic Angel Messages
        <!--<img src="title.jpg"/>-->
        </h1>
        <p class="links">
          <a href="archive.zip">Full Message Archive (ZIP, $[$(stat -c'%s' archive.zip)/(1024*1024)] MB)</a>
          <br/>
          <a href="#answers">Questions & Answers</a>
        </p>
EOF

function html_escape() {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
}

echo '<ul>' >> "$OUTFILE"
while read FILENAME; do
  PDFFILENAME="$FILENAME".pdf
  COMPOUND_TITLE=$(grep -i '<title>' "$FILENAME" | sed 's!.*<title>\(.*\)</title>.*!\1!' | sed 's/.*ANGEL[] :}]\+//i' | sed 's/[^0-9]*\([0-9]\+.*\)/\1/')
  TITLE=$(echo $COMPOUND_TITLE | cut -d, -f1 | sed 's/5th day/5th day of lunar cycle/i' | sed 's/day/Day/' | sed 's/moon/Lunar/' | sed 's/lunar/Lunar/' | sed 's/thDay/th Day/' | sed 's/ Happiness//') # deal with inconsistencies
  SUBTITLE=$(echo $COMPOUND_TITLE | cut -d, -f2- | sed 's/,//g' | sed 's/3rd day of lunar cycle //i')
  TITLE_E=$(echo $TITLE | html_escape)
  SUBTITLE_E=$(echo $SUBTITLE | html_escape)
  FILENAME_E=$(echo "$FILENAME" | html_escape)
  PDFFILENAME_E=$(echo "$PDFFILENAME" | html_escape)
  set +e
  IS_MOON=$(echo $TITLE $SUBTITLE | grep -iE lunar\|moon)
  IS_SPECIAL=$(echo $TITLE | grep -iE special.\*message)
  if [ ! -z "$IS_SPECIAL" ]; then continue; fi
  if [ -z "$IS_MOON" ]; then
      SIGN=$(echo $TITLE | cut -d\  -f2 | cut -d: -f1 | tr '[:upper:]' '[:lower:]')
      IMG=assets/images/signs/$SIGN.gif
      ALT="Earth Zone Angel: $SIGN"
  else
      IMG=assets/images/moonphases/$(echo $TITLE | sed 's/\([0-9]\+\).*/\1/').gif
      ALT="Moon Angel"
  fi
  set -e
  echo "<li><img src='$IMG' alt='$ALT'/><a class='htmlfile' href='$FILENAME_E'>$TITLE_E:<br/>$SUBTITLE_E</a> <a class='pdffile' href='$PDFFILENAME_E'>[PDF]</a></li>" >> "$OUTFILE"
done < "$LISTFILE"
echo '</ul>' >> "$OUTFILE"

echo '<h2 id="answers">Questions and Answers</h2></a>' >> "$OUTFILE"

cat assets/qa.html >> "$OUTFILE"
  
echo '</div>' >> "$OUTFILE" # col
echo '<div class="col-lg-3"></div>' >> "$OUTFILE"
echo '</div>' >> "$OUTFILE" # row
echo '</body> </html>' >> "$OUTFILE"

rm -f "$LISTFILE"
