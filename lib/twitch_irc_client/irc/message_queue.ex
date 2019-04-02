defmodule TwitchIrcClient.Irc.Config.MessageQueue do
    def new() do
        %{
            JOIN: :queue.new()
        }
    end

    def add_message(message_queue, message_type, ref) do
        queue = Map.get(message_queue, ref)
        Map.put(message_queue, :queue.in(queue, message))
    end

    def pop_message(message_queue, message_type) do
        queue = Map.get(message_queue, message_type)
        case :queue.out_r(queue) do
            {:empty, internal_queue} ->
                {:error, :empty_queue, internal_queue}
            {{:value, value}, internal_queue} ->
                {:ok, value, Map.put(message_queue, message_type, internal_queue)}
        end
    end
end