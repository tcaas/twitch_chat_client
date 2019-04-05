defmodule TwitchIrcClient.Parser do
  alias TwitchIrcClient.Parser.RawMessage

  import NimbleParsec

  tag = utf8_string([not: ?=, not: ?;, not: ?\s], min: 1)
  |> ignore(string("="))
  |> choice([
    utf8_string([not: ?=, not: ?;, not: ?\s], min: 1),
    optional(string("")) |> replace(:empty)
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
    optional(string("")) |> replace(:no_tags)
  ])
  |> choice([
    ignore(string(":")) |> concat(prefix) |> ignore(string(" ")),
    optional(string("")) |> replace(:no_prefix)
  ])
  |> concat(command)
  |> ignore(string(" "))
  |> choice([
    channel,
    optional(string("")) |> replace(:no_channel)
  ])
  |> choice([
    ignore(string(" ")) |> concat(params),
    optional(string("")) |> replace(:no_params)
  ])

  def parse_message(message) do
    case message_parser(message) do
      {:ok, data, _reminder, _, _, _} ->
        data
      {:error, error} -> {:error, error}
    end


  end
end
