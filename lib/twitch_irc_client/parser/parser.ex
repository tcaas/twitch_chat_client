defmodule TwitchIrcClient.Parser do
  alias TwitchIrcClient.Parser.RawMessage

  def parse_message(":" <> message) do
    message
    |> clean_message()
    |> String.split(" ", parts: 4)
    |> RawMessage.new()
  end

  def parse_message("@" <> message) do
    message
    |> clean_message()
    |> String.split(" ", parts: 5)
    |> parse_tags()
    |> clean_address()
    |> RawMessage.new()
  end

  def parse_message(message) do
    message
    |> RawMessage.new()
  end

  defp clean_address(message) do
    List.update_at(message, 1, fn(":" <> address) ->
        address
    end)
  end

  defp parse_tags(message) do
    List.update_at(message, 0, fn(tags) ->
        tags
        |>  String.split(";")
    end)
  end

  defp clean_message(message) do
    String.trim(message, "\r\n")
  end
end
