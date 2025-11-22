defmodule AstrologersBot do
  @doc """
  Starts the bot
  """
  def work_mode, do: Application.get_env(:astrologers_bot, :work_mode)
end
