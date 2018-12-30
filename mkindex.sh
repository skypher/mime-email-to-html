#!/bin/bash

set -x
set -e

which find sed grep stat # dep sanity check

test ! -z "$1"

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
    <h1>
    Hermetic Angel Messages
    <!--<img src="title.jpg"/>-->
    </h1>
    <div class="col-md-6">
        <div class="intro">
            <p class="beloved">Beloved,</p>
            <p>welcome to the communications of the 360 Hermetic Spirits of the Earth Zone and the 28 Hermetic Spirits of the Lunar Cycle.</p>
            <p>We have been described by Franz Bardon, teacher of High Magic,
            and Abramelin, Western medieval sage.</p>
            <!--<p class="greeting">As above, so below,<br/>as within, so without.<br/>We are all One.</p>-->
            <p>As above, so below, as within, so without. We are all One.</p>
            <p>Starting years ago, we have communicated important messages through our messenger Cynthia Rose Schlosser,
            and she reposts these messages on a daily basis through Yahoo! Groups, as befits the current
            position of the Sun in the Western Tropical Zodiac, and the Moon's passage through its
            28 day cycle.</p>
            <p>This website collects these messages as they come in and makes them available to a wider
            audience, a vital step in these times where the Alpha and the Omega are destined to merge on Earth.
            More specifically, it makes the messages and their contents discoverable by search engines.
            It also provides PDF versions of the messages and a ZIP file for easy download of all messages
            presented.</p>

            <div class="conduit">
                <p>I am Blue Magician, and these spirits are part of you and me. Like Cynthia Schlosser,
                I serve as a conduit for them. This site is dedicated so all my sincere companions in our
                journey to Self.</p>
                <p>If you find this site useful, please send an email message to thesilverstarlight@fastmail.com
                to let me know. All questions and comments are welcome, even if it is just to say "Hello".</p>

                <div class="closing">
                    <p class="closing">In humility, service and unconditional love,</p>
                    <p class="signature">Blue Magician<br/>British Columbia, December 2018</p>
                </div>
            </div>
            <p><a href="archive.zip">Full Message Archive (ZIP, $[$(stat -c'%s' archive.zip)/(1024*1024)] MB)</a></p>
        </div>
    </div>
    <div class="col-md-6">
EOF

echo '<ul>' >> "$OUTFILE"
while read FILENAME; do
  PDFFILENAME="$FILENAME".pdf
  COMPOUND_TITLE=$(grep -i '<title>' "$FILENAME" | sed 's!.*<title>\(.*\)</title>.*!\1!' | sed 's/.*ANGEL[] :}]\+//i' | sed 's/[^0-9]*\([0-9]\+.*\)/\1/')
  TITLE=$(echo $COMPOUND_TITLE | cut -d, -f1 | sed 's/day/Day/' | sed 's/moon/Lunar/' | sed 's/lunar/Lunar/')
  SUBTITLE=$(echo $COMPOUND_TITLE | cut -d, -f2-)
  TITLE_E=$(echo $TITLE | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  SUBTITLE_E=$(echo $SUBTITLE | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  FILENAME_E=$(echo "$FILENAME" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  PDFFILENAME_E=$(echo "$PDFFILENAME" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  set +e
  IS_MOON=$(echo $TITLE | grep -iE lunar\|moon)
  if [ -z "$IS_MOON" ]; then
      SIGN=$(echo $TITLE | cut -d\  -f2 | cut -d: -f1 | tr '[:upper:]' '[:lower:]')
      IMG=assets/images/signs/$SIGN.gif
      ALT="Earth Zone Angel: $SIGN"
  else
      IMG=assets/images/moonphases/$(echo $TITLE | sed 's/\([0-9]\).*/\1/').gif
      ALT="Moon Angel"
  fi
  set -e
  echo "<li><img src='$IMG' alt='$ALT'/><a class='htmlfile' href='$FILENAME_E'>$TITLE_E:<br/>$SUBTITLE_E</a> <a class='pdffile' href='$PDFFILENAME_E'>[PDF]</a></li>" >> "$OUTFILE"
done < "$LISTFILE"
echo '</ul>' >> "$OUTFILE"
  
echo '</div></div></body> </html>' >> "$OUTFILE"

rm -f "$LISTFILE"
