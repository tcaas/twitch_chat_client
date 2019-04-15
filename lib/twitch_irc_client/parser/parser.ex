defmodule TwitchIrcClient.Parser do
  import NimbleParsec

  tag = utf8_string([not: ?=, not: ?;, not: ?\s], min: 1)
  |> ignore(string("="))
  |> choice([
    utf8_string([not: ?=, not: ?;, not: ?\s], min: 1),
    optional(string("")) |> replace(nil)
  ])
  |> optional(ignore(string(";")))

  tags = repeat(tag) |> tag(:tags)

  prefix = utf8_string([not: ?\s], min: 1) |> tag(:prefix)

  command = choice([
    integer(3),
    utf8_string([not: ?\s], min: 1)
  ])
  |> tag(:command)

  channel = utf8_string([not: ?\s], min: 1) |> tag(:channel)

  params = choice([
    utf8_string([], min: 1),
    optional(string("")) |> replace(:empty)
  ])
  |> tag(:params)

  defparsec :message_parser,
  choice([
    ignore(string("@")) |> concat(tags) |> ignore(string(" ")),
    optional(string("")) |> replace(:tags)
  ])
  |> choice([
    ignore(string(":")) |> concat(prefix) |> ignore(string(" ")),
    optional(string("")) |> replace(:prefix)
  ])
  |> concat(command)
  |> ignore(string(" "))
  |> choice([
    channel,
    optional(string("")) |> replace(:channel)
  ])
  |> choice([
    ignore(string(" ")) |> concat(params),
    optional(string("")) |> replace(:params)
  ])

  def parse_message(message) do
    case message_parser(message) do
      {:ok, data, _reminder, _, _, _} ->
        data
        |> parsed_message_to_map
      {:error, error, _, _, _, _} -> {:error, error}
    end
  end

  defp parsed_message_to_map(parsed_message) do
    parsed_message
    |> Enum.reduce(%{}, fn(values, map) ->
      case values do
        {:tags, tag_values} when is_list(tag_values) -> Map.put(map, :tags, parse_raw_tags(tag_values))
        #{:command, [command]} -> Map.put(map, :command, parse_command(command))
        #{:params, [params]} -> Map.put(map, :params, parse_params(params))
        {key, [value]} when is_atom(key) and is_integer(value) -> Map.put(map, key, value)
        {key, [value]} when is_atom(key) and is_bitstring(value) -> Map.put(map, key, String.replace(value, "\r\n", ""))
        key when is_atom(key) -> Map.put(map, key, nil)
      end
    end)
  end

  defp parse_raw_tags(tag_values) do
    tag_values
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn([key, value], map) ->
      Map.put(map, parse_tag_key(key), value)
    end)
  end

  defp parse_tag_key(key) do
    key
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  defp parse_command(command) when is_integer(command) do
    Integer.to_string(command)
    |> String.to_atom()
  end

  defp parse_command(command) when is_bitstring(command) do
    String.to_atom(command)
  end

  defp parse_params(":" <> params) do
    params
  end
end
