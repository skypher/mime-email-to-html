#!/usr/bin/python3
from bs4 import BeautifulSoup
from sys import argv
from os.path import splitext

def process_html(fname, encoding):
    with open(argv[1], encoding=encoding) as fp:
        soup = BeautifulSoup(fp, 'html.parser')

        # just get the relevant body
        mlmsg_matches = soup.find_all('div', 'moz-forward-container')
        #mlmsg_matches = soup.find_all(id='ygrp-text')
        #assert(len(mlmsg_matches) == 1)
        mlmsg = mlmsg_matches[0]

        # remove spurious table
        mlmsg.find_all('table', 'moz-email-headers-table')[0].extract()

        # keep existing CSS
        style_matches = soup.find_all('style')
        assert(len(style_matches) == 1)
        style = style_matches[0]

        # build and write new doc
        outdoc = '<html><head><meta charset="UTF-8"/><link type="text/css" rel="stylesheet" href="/style.css"/>%s</head><body>%s</body></html>' % (style, mlmsg)
        
        with open(argv[2], 'w', encoding='utf-8') as outfp:
            outfp.write(outdoc)


# args: infile outfile
assert(len(argv) == 3)

try:
    print('Trying to process as UTF-8...')
    process_html(argv[1], 'utf-8')
except UnicodeDecodeError:
    # sometimes utf-8 is declared but contents are latin1
    print('Failed to process as UTF-8, trying Latin1.')
    process_html(argv[1], 'iso-8859-1')
