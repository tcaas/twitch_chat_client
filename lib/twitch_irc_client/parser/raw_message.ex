defmodule TwitchIrcClient.Parser.RawMessage do
  defstruct [:tags, :source, :command, :channel, :parameters]

  @allowed_commands ~w(CLEARCHAT CLEARMSG GLOBALUSERSTATE PRIVMSG ROOMSTATE USERNOTICE NOTICE USERSTATE PARTED JOINED DISCONNECTED JOIN)a

  def new(message) when is_list(message) and length(message) == 3 do
    IO.inspect(message)
    map = message
    |> Enum.with_index()
    |> Enum.map(fn({part, index}) ->
      case index do
        0 -> {:source, part}
        1 -> {:command, part}
        2 -> {:parameters, part}
      end
    end)
    |> Map.new()

    case update_and_check_command(struct(__MODULE__, map)) do
      {:ok, struct} -> struct
      :error -> {:unknown, message}
    end
  end

  def new(message) when is_list(message) and length(message) == 4 do
    IO.inspect(message)
    map = message
    |> Enum.with_index()
    |> Enum.map(fn({part, index}) ->
      case index do
        0 -> {:tags, part}
        1 -> {:source, part}
        2 -> {:command, part}
        3 -> {:channel, part}
      end
    end)
    |> Map.new()

    case update_and_check_command(struct(__MODULE__, map)) do
      {:ok, struct} ->
        struct
        |> parse_tags()
      :error -> {:unknown, message}
    end
  end

  def new(message) when is_list(message) and length(message) == 5 do
    IO.inspect(message)
    map = message
    |> Enum.with_index()
    |> Enum.map(fn({part, index}) ->
      case index do
        0 -> {:tags, part}
        1 -> {:source, part}
        2 -> {:command, part}
        3 -> {:channel, part}
        4 -> {:parameters, part}
      end
    end)
    |> Map.new()

    case update_and_check_command(struct(__MODULE__, map)) do
      {:ok, struct} ->
        struct
        |> parse_tags()
      :error -> {:unknown, message}
    end
  end

  # testusertcaas  bquce1e7ekhfyvbrwxz01rrwnd9g4m config = TwitchIrcClient.Irc.Config.new("testusertcaas", "vzu7hyqst0959owgtixospzp2g7qis", false, :irc, 10_000)
  # nkyian         8w3mpwgkd40ye1tb1q7dq1xhx0goe4 config = TwitchIrcClient.Irc.Config.new("nkyian", "8w3mpwgkd40ye1tb1q7dq1xhx0goe4", false, :irc, 10_000)
  def new(message) do
    IO.inspect(message)
    {:unknown, message}
  end

  def parse_tags(%__MODULE__{tags: tags} = raw_message) do
    Map.put(raw_message, :tags, parse_tags(tags))
  end

  def parse_tags(tags) when is_list(tags) do
    tags
    |> Enum.reduce(%{}, fn(raw_tag, map) ->
      list_tag = raw_tag
      |> String.split("=", parts: 2)

      key = Enum.at(list_tag, 0)
      value = Enum.at(list_tag, 1)

      Map.put(map, String.to_atom(String.replace(key, "-", "_")), value)
    end)
  end

  defp update_and_check_command(%__MODULE__{command: command} = raw_message) do
    command_atom = String.to_atom(command)

    case Enum.member?(@allowed_commands, command_atom) do
       true -> {:ok, %__MODULE__{raw_message | command: command_atom}}
       false -> :error
    end
  end
end
