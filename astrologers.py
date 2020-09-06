from image import render_image
from hashlib import sha1
from telegram import Update
from telegram import InlineQueryResultCachedPhoto
from telegram.ext import CallbackContext
from telegram.ext import Updater
from telegram.ext import CommandHandler
from telegram.ext import InlineQueryHandler
from telegram.ext import MessageHandler
from telegram.ext import Filters
from text import text_renderable
import os

TOKEN = os.environ['ASTROLOGERS_BOT_TOKEN']
ARCHIVE_ID = os.environ['ASTROLOGERS_PRIVATE_CHANNEL']
updater = Updater(TOKEN, use_context=True)
dispatcher = updater.dispatcher


def start(update: Update, context: CallbackContext):
    update.effective_message.reply_text('Отправь текст который надо загероить и я пришлю картиночьку.\n\n'
                                        'А еще можно в инлайне-режиме, тип "@{} абугабуга" '
                                        'прям в поле сообщения нутыпонел, только там ограничение по символам жесть'
                                        .format(context.bot.username))


def astrologize(update: Update, context: CallbackContext):
    text = update.effective_message.text
    if not text_renderable(text):
        update.effective_message.reply_text('У тебя там символы какие-то непонятные')
        return
    rendered_image = render_image(text)
    update.effective_message.reply_photo(photo=rendered_image)


def astrologize_inline(update: Update, context: CallbackContext):
    query = update.inline_query
    text = query.query
    if text == '':
        return
    if not text_renderable(text):
        message = context.bot.send_photo(chat_id=ARCHIVE_ID, photo=open('error.jpg', 'rb'))
        update.inline_query.answer([
            InlineQueryResultCachedPhoto('symbol_error', photo_file_id=message.photo[0].file_id)
        ])
        return
    rendered_image = render_image(text)
    message = context.bot.send_photo(chat_id=ARCHIVE_ID, photo=rendered_image)
    query_cache_id = sha1(query.query.encode('utf-8')).hexdigest()
    update.inline_query.answer([
        InlineQueryResultCachedPhoto(query_cache_id, photo_file_id=message.photo[0].file_id)
    ])


def source(update: Update, context: CallbackContext):
    update.effective_message.reply_text(text='https://github.com/graynk/astrologers_bot')


if __name__ == '__main__':
    start_handler = CommandHandler(str('start'), start)
    source_handler = CommandHandler(str('source'), source)
    astro_handler = MessageHandler(Filters.text, astrologize)
    astro_inline_handler = InlineQueryHandler(astrologize_inline)

    dispatcher.add_handler(start_handler)
    dispatcher.add_handler(source_handler)
    dispatcher.add_handler(astro_handler)
    dispatcher.add_handler(astro_inline_handler)

    updater.start_polling()
    updater.idle()
