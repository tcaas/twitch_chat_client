defmodule TwitchIrcClient.Irc.MessageQueue do
    defstruct channels: %{}

    def new(channels \\ []) do
        channels = channels
        |> Enum.map(fn(channel) ->
            {channel, %{}}
        end)
        |> Map.new()

        %__MODULE__{channels: channels}
    end

    def add_channel(%__MODULE__{channels: channels} = module, channel) do
        channels = Map.put(channels, channel, %{})
        %__MODULE__{module | channels: channels}
    end

    def delete_channel(%__MODULE__{channels: channels} = module, channel) do
        channels = Map.delete(channels, channel)
        %__MODULE__{module | channels: channels}
    end

    def add_message(%__MODULE__{channels: channels} = module, channel, type, ref, from, message) do

    end
end
