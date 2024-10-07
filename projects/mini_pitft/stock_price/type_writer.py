#!/usr/bin/env python3

class TypeWriter(object):
  def __init__(self, canvas, bitmaps, width=40, height=20):
    self._canvas = canvas
    self._bitmaps = bitmaps
    self._width = width
    self._height = height
    self.Clear()

  def Clear(self):
    self._canvas.Clear()
    self._row = 0
    self._col = 0

  def Print(self, color, text):
    def XX(x):
      if x:
        return 'X'
      else:
        return ' '

    for ch in text:
      # FIXME print(f'{self._row}:{self._col}: {ch}')
      if ch == '\n':
        self._row += 10
        self._col = 0
      elif ch == '\r':
        self._col = 0
      else:
        bitmap = self._bitmaps[ch]
        pixels = [[(color, XX(bitmap[row][col])) for col in range(len(bitmap[row]))]
                  for row in range(len(bitmap))]
        self._canvas.Paste(self._row, self._col, pixels)
        self._col += len(pixels[0])
