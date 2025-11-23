defmodule AstrologersBot.ChatPicChain do
  @moduledoc false

  use Telegex.Chain, :message

  @impl true
  def match?(%{text: text, chat: %{type: chat_type}} = _message, _context)
      when is_nil(text) or chat_type != "private" do
    false
  end

  @impl true
  def match?(%{text: text} = _message, _context), do: String.length(text) < 750

  @impl true
  def handle(%{chat: %{id: chat_id}, text: text} = _message, context) do
    # I see no good way to avoid writing the image to a file. Telegex documentation is not exactly forthcoming.
    file_name = AstrologersBot.ImageFrame.write_image!(text)

    {:ok, %Telegex.Type.Message{photo: [%{file_id: file_id} | _]}} =
      Telegex.send_photo(AstrologersBot.archive_id(), file_name)

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
