import argparse
import sys
from image import render_image
from text import text_renderable

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate a Heroes III style info-picture from file')
    parser.add_argument('file', metavar='file', type=str, help='Text file')
    args = parser.parse_args()
    with open(args.file, 'r') as file:
        text = file.read()
        if not text_renderable(text):
            print('Unsupported symbols in file', file=sys.stderr)
            sys.exit()
        rendered_image = render_image(text)
        rendered_image.save(args.file+'.png', 'png')