#!/usr/bin/python3
from bs4 import BeautifulSoup
from sys import argv
import cgi
from os.path import splitext

def process_html(fname, encoding):
    with open(argv[1], encoding=encoding) as fp:
        soup = BeautifulSoup(fp, 'html.parser')

        # keep existing CSS
        style_matches = soup.find_all('style')
        assert(len(style_matches) == 1)
        original_style = style_matches[0]

        # just get the relevant body
        mlmsg_matches = soup.find_all('div', 'moz-forward-container')
        #mlmsg_matches = soup.find_all(id='ygrp-text')
        #if (len(mlmsg_matches) > 0): # some messages don't have it
        mlmsg = mlmsg_matches[0]
        # remove spurious table if it exists
        try:
            mlmsg.find_all('table', 'moz-email-headers-table')[0].extract()
        except:
            pass
        pdflink = argv[2] + '.pdf'
        custom_header = '<div class="custom-header"><h1><a href="/">Hermetic Angel Messages</a></h1><p class="subtitle"><a href="%s">PDF version</a></p></div>' % cgi.escape(pdflink)
        body = '<body>%s%s</body>' % (custom_header, mlmsg)
        #else:
            #soup.select('body > div > b')[0].extract()
            #body = soup.find('body').prettify()


        # build and write new doc
        meta = '<meta charset="UTF-8"/><link type="text/css" rel="stylesheet" href="../assets/style.css"/>'
        meta += original_style.prettify()
        title = '<title>%s</title>' % cgi.escape(argv[3])
        outdoc = '<html><head>%s%s</head>%s</html>' % (title, meta, body)
        
        with open(argv[2], 'w', encoding='utf-8') as outfp:
            outfp.write(outdoc)


# args: infile outfile title
assert(len(argv) == 4)

try:
    print('Trying to process as UTF-8...')
    process_html(argv[1], 'utf-8')
except UnicodeDecodeError:
    # sometimes utf-8 is declared but contents are latin1
    print('Failed to process as UTF-8, trying Latin1.')
    process_html(argv[1], 'iso-8859-1')
