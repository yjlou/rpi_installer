#!/usr/bin/env python3

import text_canvas
import colors
import common
import type_writer

import json
import os
import pprint
import sys
import urllib.request

api_key = os.getenv('FMP_KEY')

sys.path.append('.')  # to import file in the base directory.


with open(common.OUTPUT_JSON, 'r') as fp:
  bitmaps = json.load(fp)


c = text_canvas.TextCanvas()
t = type_writer.TypeWriter(c, bitmaps)

t.Clear()
for symbol in sys.argv[1:]:
  url = f'https://financialmodelingprep.com/api/v3/quote-short/{symbol}?apikey={api_key}'
  with urllib.request.urlopen(url) as req:
    data = json.load(req)
    t.Print(colors.YELLOW, f'{data[0]["symbol"]}\n')
    t.Print(colors.GREEN, f'${data[0]["price"]}')
