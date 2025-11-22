defmodule AstrologersBot do
  @moduledoc false

  @doc """
  Starts the bot.
  """
  def work_mode, do: Application.get_env(:astrologers_bot, :work_mode)

  @doc """
  Returns the channel id of the archive channel, where the photos are being sent to.
  """
  def archive_id, do: Application.get_env(:astrologers_bot, :archive_id)
end
