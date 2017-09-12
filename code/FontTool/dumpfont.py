import sys
import string
from collections import OrderedDict
from PIL import ImageFont
from PIL.Image import core


FONT_CHARS = list(string.digits) + list(string.ascii_uppercase) + list(string.ascii_lowercase) + list(string.punctuation)


def get_font_bitmap(font_name, font_size, antialias=False):
    font = ImageFont.truetype(font=font_name, size=font_size)
    antialias_mode = 'L' if antialias else '1'
    bitmap_chars = OrderedDict()

    for c in FONT_CHARS:
        bitmap = font.getmask(c, mode=antialias_mode)
        bitmap_width = bitmap.size[0]
        bitmap_height = bitmap.size[1]

        bitmap_chars[c] = (bitmap_width, bitmap_height, bitmap)

    return bitmap_chars


def dump_font_bitmap(file_name, bitmap_chars):
    char_bytes = []

    for c, data in bitmap_chars.items():
        bitmap_bytes = bytearray()
        bitmap_bytes.append(ord(c))
        bitmap_bytes.extend(data[0:2])
        for y in range(data[1]):
            for x in range(data[0]):
                bitmap_bytes.append(data[2].getpixel((x, y)))

        char_bytes.append(bitmap_bytes)
        print(c, end='')
    print('')

    with open(file_name, 'wb') as f:
        for char in char_bytes:
            f.write(char)

    print('Characters written: {}'.format(len(char_bytes)))


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('Usage: python {} <font_name> <font_size> <out_name>'.format(sys.argv[0]))
        sys.exit(1)

    font_name = sys.argv[1]
    font_size = int(sys.argv[2])
    out_name = sys.argv[3]

    bitmap_chars = get_font_bitmap(font_name, font_size)
    dump_font_bitmap(out_name, bitmap_chars)
