defmodule TwitchIrcClient.Parser do
  import NimbleParsec
  

  tags =
    utf8_string([], min: 1)
    ignore(string("="))
    |> utf8_string([], min: 1)

  defparsec(:tags, tags)

  def parse_message(message) when is_list(message) do
    message
    |> to_string()
    |> parse_message()
  end

  def parse_message(":" <> message) do
    message
    |> String.split(" ", parts: 4)
  end

  def parse_message("@" <> message) do
    message
    |> String.split(" ", parts: 5)
    |> parse_tags()
    |> clean_address()
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
end
