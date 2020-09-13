from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw
from io import BytesIO
from text import wrap_text
import math

lt = Image.open('interface/lt.png')
top = Image.open('interface/top.png')
rt = Image.open('interface/rt.png')
left = Image.open('interface/left.png')
right = Image.open('interface/right.png')
lb = Image.open('interface/lb.png')
bot = Image.open('interface/bot.png')
rb = Image.open('interface/rb.png')
ok = Image.open('interface/ok.png')
fill = Image.open('interface/fill.png')

font = ImageFont.truetype('times-new-roman.ttf', 12)
calculation_image = Image.new(mode='RGB', size=(1, 1))
calculation_draw = ImageDraw.Draw(calculation_image)

side_border_width = left.width
side_border_height = left.height
vert_border_width = top.width
vert_border_height = top.height
corner_width = lt.width
corner_height = lt.height

padding_sides = 15
padding_top = 20
padding_bot = 10
spacing_size = 21

padding = (padding_sides * 2, padding_top + padding_bot)
ok_bot_offset = vert_border_height + 30 + ok.height


def calculate_frame_size(text):
    text_size = calculation_draw.textsize(text, font)
    return max(text_size[0] + padding[0] + 2 * side_border_width - spacing_size, 100), \
           max(text_size[1] + padding[1] + 2 * vert_border_height + ok_bot_offset, 100)


def construct_frame(size):
    vert_border_count = math.ceil(float(size[0] - (2 * corner_width)) / vert_border_width)
    side_border_count = math.ceil(float(size[1] - (2 * corner_height)) / side_border_height)

    new_size = (
        2 * corner_width + vert_border_count * vert_border_width,
        2 * corner_height + side_border_count * side_border_height,
    )

    dst = Image.new(mode='RGBA', size=new_size, color=(0, 0, 0, 0))

    dst.paste(lt, (0, 0))
    dst.paste(rt, (dst.width - corner_width, 0))
    dst.paste(lb, (0, dst.height - corner_height))
    dst.paste(rb, (dst.width - corner_width, dst.height - corner_height))

    for i in range(vert_border_count):
        width_offset = corner_width + i * vert_border_width
        dst.paste(top, (width_offset, 0))
        dst.paste(bot, (width_offset, dst.height - vert_border_height))

    for i in range(side_border_count):
        height_offset = corner_height + i * side_border_height
        dst.paste(left, (0, height_offset))
        dst.paste(right, (dst.width - side_border_width, height_offset))

    return dst


def construct_fill(size):
    dst = Image.new(mode='RGBA', size=size, color=(0, 0, 0, 0))
    current_width = side_border_width
    current_height = vert_border_height
    while current_height < dst.height - vert_border_height:
        while current_width < dst.width - side_border_width:
            dst.paste(fill, (current_width, current_height))
            current_width += fill.width
        current_height += fill.height
        current_width = left.width
    return dst


def splice(background, frame):
    dst = Image.new(mode='RGBA', size=(background.width, background.height), color=(0, 0, 0, 0))
    dst.paste(background, (0, 0))
    dst.paste(frame, (0, 0), mask=frame)
    dst.paste(ok, (int((dst.width - ok.width) / 2), int(dst.height - ok_bot_offset)))
    return dst


def add_text(image, text):
    draw = ImageDraw.Draw(image)
    draw.fontmode = '1'
    size = draw.textsize(text, font)
    middle_width = (image.width - size[0] + spacing_size) / 2
    middle_height = (image.height - size[1] - padding_bot - ok_bot_offset + padding_top) / 2
    draw.text((middle_width, middle_height), text, (255, 255, 255), font=font, align='center')
    return image


def render_image(text):
    text = wrap_text(text)
    size = calculate_frame_size(text)
    frame = construct_frame(size)
    background = construct_fill(frame.size)
    spliced = splice(background, frame)
    result = add_text(spliced, text)
    img_file = BytesIO()
    result.save(img_file, 'png')
    img_file.seek(0)
    return img_file
