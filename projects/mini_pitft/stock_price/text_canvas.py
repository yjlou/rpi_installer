#!/usr/bin/env python3

import colors

class TextCanvas(object):
  def __init__(self, width=40, height=20):
    self._width = width
    self._height = height
    self.Clear()

  def Clear(self):
    self._buf = [[(colors.BLACK, ' ') for col in range(self._width)]
                 for row in range(self._height)]

  def Paste(self, row_, col_, pixels):
    for row in range(len(pixels)):
      ROW = row_ + row
      if ROW >= self._height:
        continue
      for col in range(len(pixels[row])):
        COL = col_ + col
        if COL >= self._width:
          continue
        self._buf[ROW][COL] = pixels[row][col]
    self.Draw()

  def Draw(self):
    print("\033[H\033[J", end="")

    for row in range(self._height):
      for col in range(self._width):
        print(f'{self._buf[row][col][0]}{self._buf[row][col][1]}', end='')
      if row < self._height:  # only return when the row is inside the height.
        print('')
