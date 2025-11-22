defmodule AstrologersBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    updates_handler =
      if AstrologersBot.work_mode() == :webhook do
        AstrologersBot.UpdatesAngler
      else
        AstrologersBot.UpdatesPoller
      end

    children = [
      # Starts a worker by calling: AstrologersBot.Worker.start_link(arg)
      # {AstrologersBot.Worker, arg}

      updates_handler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AstrologersBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
