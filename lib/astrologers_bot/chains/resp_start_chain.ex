defmodule AstrologersBot.RespStartChain do
  @moduledoc false

  use Telegex.Chain, {:command, :start}

  @impl true
  def match?(%{text: text, chat: %{type: "private"}}, _context) when text != nil do
    String.starts_with?(text, @command)
  end

  @impl true
  def match?(_message, _context), do: false

  @impl true
  def handle(
        %{chat: %{id: chat_id}, text: _text} = _message,
        %{bot: %{username: bot_name}} = context
      ) do
    send_reply = %{
      method: "sendMessage",
      chat_id: chat_id,
      text: """
      Send me the text you need Hero\\-ized and I'll send you a pic back\\.

      It also works in the inline mode, just type "`@#{bot_name} amogus`" right in the message field \\(but there's a severe length limit there\\)\\.
      """,
      parse_mode: "MarkdownV2",
      disable_web_page_preview: true
    }

    context = %{context | payload: send_reply}

    {:done, context}
  end
end
