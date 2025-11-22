defmodule AstrologersBot.InlinePicChain do
  @moduledoc false

  use Telegex.Chain, :inline_query

  @impl true
  def match?(_query, _context), do: true

  @impl true
  def handle(query, context) do
    {:ok, %Telegex.Type.Message{photo: [%{file_id: file_id} | _]}} =
      Telegex.send_photo(AstrologersBot.archive_id(), "app/interface/ok.png")

    results = [
      %Telegex.Type.InlineQueryResultCachedPhoto{
        id: :crypto.hash(:md5, query.query) |> Base.encode16(case: :lower),
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
