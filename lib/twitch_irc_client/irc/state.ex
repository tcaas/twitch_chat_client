defmodule TwitchIrcClient.Irc.State do
  defstruct [:config, :socket, :roomstate, :userstate]

  alias TwitchIrcClient.Irc.Config

  def new(%Config{} = config) do
    %__MODULE__{
      config: config,
      socket: nil,
      roomstate: nil,
      userstate: nil
    }
  end

  def set_socket(%__MODULE__{} = state, socket) do
    %__MODULE__{state | socket: socket}
  end
end
