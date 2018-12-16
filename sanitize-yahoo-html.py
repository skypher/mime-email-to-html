#!/usr/bin/python3
from bs4 import BeautifulSoup
from sys import argv
from os.path import splitext

def process_html(fname, encoding):
    with open(argv[1], encoding=encoding) as fp:
        soup = BeautifulSoup(fp, 'html.parser')

        mlmsg_matches = soup.find_all('div', 'moz-forward-container')
        #mlmsg_matches = soup.find_all(id='ygrp-text')
        #assert(len(mlmsg_matches) == 1)
        mlmsg = mlmsg_matches[0]

        style_matches = soup.find_all('style')
        assert(len(style_matches) == 1)
        style = style_matches[0]

        outdoc = '<html><head><link type="text/css" rel="stylesheet" href="style.css"/>%s</head><body>%s</body></html>' % (style, mlmsg)
        
        with open(argv[2], 'w', encoding='utf-8') as outfp:
            outfp.write(outdoc)


# args: infile outfile
assert(len(argv) == 3)

try:
    process_html(argv[1], 'utf-8')
except UnicodeDecodeError:
    # sometimes utf-8 is declared but contents are latin1
    process_html(argv[1], 'iso-8859-1')
