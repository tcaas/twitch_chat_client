defmodule TwitchIrcClient.Irc.State do
  defstruct [:config, :socket, :roomstate, :userstate, :channels, :message_queue]

  alias TwitchIrcClient.Irc.Config
  alias TwitchIrcClient.Irc.Channel
  alias TwitchIrcClient.Irc.MessageQueue

  def new(%Config{} = config) do
    %__MODULE__{
      config: config,
      socket: nil,
      roomstate: nil,
      userstate: nil,
      channels: channels,
      message_queue: %{}
    }
  end

  def set_socket(%__MODULE__{} = state, socket) do
    %__MODULE__{state | socket: socket}
  end

  def add_to_message_queue(%__MODULE__{message_queue: message_queue} = state, message_type, ref) do
    %__MODULE__{state | message_queue: MessageQueue.add_message(message_queue, message_type, ref)}
  end

  def pop_from_message_queue(%__MODULE__{message_queue: message_queue} = state, message_type) do
    case MessageQueue.pop_message(message_queue, message_type) do
      {:ok, value, message_queue} ->
        {:ok, value, %__MODULE__{state | message_queue: message_queue}}
      {:error, error, message_queue} ->
        {:error, error, state}
    end
  end
end
