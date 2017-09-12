import sys
from PIL import ImageFont
from PIL.Image import core


def render_text(font_name, font_size, text, antialias=False):
    font = ImageFont.truetype(font=font_name, size=font_size)
    antialias_mode = 'L' if antialias else '1'

    bitmap = font.getmask(text, mode=antialias_mode)

    return bitmap


def dump_bitmap(file_name, bitmap):
    bitmap_bytes = bytearray()
    bitmap_bytes.extend(bitmap.size)
    for y in range(bitmap.size[1]):
        for x in range(bitmap.size[0]):
            bitmap_bytes.append(bitmap.getpixel((x, y)))

    with open(file_name, 'wb') as f:
        f.write(bitmap_bytes)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('Usage: python {} <font_name> <font_size> <out_name>'
                  .format(sys.argv[0]))
        sys.exit(1)

    font_name = sys.argv[1]
    font_size = int(sys.argv[2])
    out_name = sys.argv[3]

    text = input("Input text to render: ")

    rendered = render_text(font_name, font_size, text)
    dump_bitmap(out_name, rendered)
