defmodule TwitchIrcClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: TwitchIrcClient.Worker.start_link(arg)
      # {TwitchIrcClient.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwitchIrcClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
