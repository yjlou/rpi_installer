#!/usr/bin/env python3

import common

import json
import pprint
from PIL import Image, ImageDraw, ImageFont
import numpy as np
import matplotlib.pyplot as plt


def gen_text(font, text):
  left, top, right, bottom = font.getbbox(text)
  # print(left, top, right, bottom)
  width, height = right - left, bottom #  - top
  # print(width, height)

  image = Image.new('L', (width, height), color=1)
  draw = ImageDraw.Draw(image)

  draw.text((0, 0), text, font=font, fill=0)

  # cut the top 3 rows out
  bitmap = np.array(image)[top:]

  # reverse color
  bitmap = [[1 - int(bitmap[row][col]) for col in range(len(bitmap[row]))] for row in range(len(bitmap))]

  if True:
    # pprint.pp(bitmap)
    for row in range(len(bitmap)):
      for col in range(len(bitmap[row])):
        if bitmap[row][col] == 1:
          print('*', end='')
        else:
          print(' ', end='')
      print('')
  else:
    plt.imshow(bitmap, cmap='gray')
    # plt.title(f"Bitmap of '{text}'")
    plt.axis('off')
    plt.show()

  return bitmap

def get_font():
  return ImageFont.truetype(common.FONT_PATH, common.FONT_SIZE)

def main():

  font = get_font()
  bitmaps = {}

  for asc in range(0, 256):
    text = chr(asc)
    bitmaps[text] = gen_text(font, text)

  pprint.pp(bitmaps)

  print(f'Saving to [{common.OUTPUT_JSON}] file ...')
  with open(common.OUTPUT_JSON, 'w', encoding='utf-8') as fp:
     json.dump(bitmaps, fp, ensure_ascii=False,
               sort_keys=True, indent=None)
  print('Done.')

main()
# gen_text(get_font(), "Cokecola $72.56")
