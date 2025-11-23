defmodule AstrologersBot.ImageFrame.Assets do
  @moduledoc """
  Loads all assets for building the image and stores them in `:persistent_term`.
  """

  @assets_dir "static"
  @images [:lt, :rt, :lb, :rb, :top, :bot, :left, :right, :fill, :ok]

  def load!() do
    for name <- @images do
      filename = Atom.to_string(name) <> ".png"
      path = Path.join(@assets_dir, filename)
      img = Image.open!(path)

      :persistent_term.put({__MODULE__, name}, img)
    end
  end

  def get(name) when is_atom(name) do
    :persistent_term.get({__MODULE__, name})
  end
end
