from line_wrapper import DocumentWrapper
from fontTools.ttLib import TTFont

# allowed_symbols = re.compile(r'[^a-zA-Zа-яА-Я0-9,.!?\[\]:\n ]')
font = TTFont('times-new-roman.ttf')


def char_in_font(unicode_char):
    for cmap in font['cmap'].tables:
        if cmap.isUnicode():
            if ord(unicode_char) in cmap.cmap:
                return True
    return False


def text_renderable(text):
    for char in text:
        if char != '\n' and not char_in_font(char):
            return False
    return True


def wrap_text(text):
    length = len(text)
    if length < 2000:
        width = 50
    elif length < 3000:
        width = 90
    else:
        width = 120
    wrapper = DocumentWrapper(width=width)
    return wrapper.wrap(text)
