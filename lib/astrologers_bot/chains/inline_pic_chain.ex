defmodule AstrologersBot.InlinePicChain do
  @moduledoc false

  use Telegex.Chain, :inline_query

  @impl true
  def match?(%{query: text} = _query, _context), do: String.length(text) < 750

  @impl true
  def handle(query, context) do
    text = query.query

    # I see no good way to avoid writing the image to a file. Telegex documentation is not exactly forthcoming.
    file_name = AstrologersBot.ImageFrame.write_image!(text)

    {:ok, %Telegex.Type.Message{photo: [%{file_id: file_id} | _]}} =
      Telegex.send_photo(AstrologersBot.archive_id(), file_name)

    results = [
      %Telegex.Type.InlineQueryResultCachedPhoto{
        id: file_name,
        photo_file_id: file_id,
        type: "photo"
      }
    ]

    context = %{
      context
      | payload: %{
          method: "answerInlineQuery",
          inline_query_id: query.id,
          results: results,
          is_personal: false
        }
    }

    {:done, context}
  end
end
