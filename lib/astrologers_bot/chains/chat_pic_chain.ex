defmodule AstrologersBot.ChatPicChain do
  @moduledoc false

  use Telegex.Chain, :message

  @impl true
  def match?(%{text: text, chat: %{type: chat_type}} = _message, _context)
      when is_nil(text) or chat_type != "private" do
    false
  end

  @impl true
  def match?(_message, _context), do: true

  @impl true
  def handle(%{chat: %{id: chat_id}} = _message, context) do
    {:ok, %Telegex.Type.Message{photo: [%{file_id: file_id} | _]}} =
      Telegex.send_photo(AstrologersBot.archive_id(), "app/interface/ok.png")

    context = %{
      context
      | payload: %{
          method: "sendPhoto",
          chat_id: chat_id,
          photo: file_id
        }
    }

    {:done, context}
  end
end
