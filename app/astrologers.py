import os
from hashlib import sha1

from telegram import InlineQueryResultCachedPhoto, Update
from telegram.ext import Application, CallbackContext, CommandHandler, InlineQueryHandler, MessageHandler
from telegram.ext import filters

from image import get_image_bytes
from text import text_renderable

TOKEN = os.environ['ASTROLOGERS_BOT_TOKEN']
ARCHIVE_ID = int(os.environ['ASTROLOGERS_PRIVATE_CHANNEL'])
application = Application.builder().token(TOKEN).build()


async def start(update: Update, context: CallbackContext):
    await update.effective_message.reply_text('Отправь текст который надо загероить и я пришлю картиночьку.\n\n'
                                              'А еще можно в инлайне-режиме, тип "@{} абугабуга" '
                                              'прям в поле сообщения нутыпонел, только там ограничение по символам '
                                              'жесть'
                                              .format(context.bot.username))


async def astrologize(update: Update, context: CallbackContext):
    text = update.effective_message.text
    if not text_renderable(text):
        await update.effective_message.reply_text('У тебя там символы какие-то непонятные')
        return
    rendered_image = get_image_bytes(text)
    await update.effective_message.reply_photo(photo=rendered_image)


async def astrologize_inline(update: Update, context: CallbackContext):
    query = update.inline_query
    text = query.query
    if text == '':
        return
    if not text_renderable(text):
        message = await context.bot.send_photo(chat_id=ARCHIVE_ID, photo=open('error.jpg', 'rb'))
        await update.inline_query.answer([
            InlineQueryResultCachedPhoto('symbol_error', photo_file_id=message.photo[0].file_id)
        ])
        return
    rendered_image = get_image_bytes(text)
    message = await context.bot.send_photo(chat_id=ARCHIVE_ID, photo=rendered_image)
    query_cache_id = sha1(query.query.encode('utf-8')).hexdigest()
    await update.inline_query.answer([
        InlineQueryResultCachedPhoto(query_cache_id, photo_file_id=message.photo[0].file_id)
    ])


async def source(update: Update, context: CallbackContext):
    await update.effective_message.reply_text(text='https://github.com/graynk/astrologers_bot')


if __name__ == '__main__':
    start_handler = CommandHandler(str('start'), start)
    source_handler = CommandHandler(str('source'), source)
    astro_handler = MessageHandler(filters.TEXT, astrologize)
    astro_inline_handler = InlineQueryHandler(astrologize_inline)

    application.add_handler(start_handler)
    application.add_handler(source_handler)
    application.add_handler(astro_handler)
    application.add_handler(astro_inline_handler)

    application.run_polling()
