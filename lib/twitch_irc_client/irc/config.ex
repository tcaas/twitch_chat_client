defmodule TwitchIrcClient.Irc.Config do
  defstruct nick: nil,
            oauth_token: nil,
            ssl: true,
            type: nil,
            host: nil,
            port: nil,
            timeout: nil,
            channels: nil

  def new(nick \\ :anonymous, oauth_token \\ nil, ssl \\ true, type \\ :irc, timeout \\ 10_000, channels \\ [])
      when is_boolean(ssl) and is_atom(type) and is_integer(timeout) do
    {host, port} = default_config(ssl, type)

    %__MODULE__{
      nick: nick,
      oauth_token: oauth_token,
      ssl: ssl,
      type: type,
      host: host,
      port: port,
      timeout: timeout,
      channels: channels
    }
  end

  defp default_config(ssl, type) when is_boolean(ssl) and is_atom(type) do
    cond do
      ssl == true and type == :ws -> {"irc-ws.chat.twitch.tv", 443}
      ssl == true and type == :irc -> {"irc.chat.twitch.tv", 6697}
      ssl == false and type == :ws -> {"irc-ws.chat.twitch.tv", 80}
      ssl == false and type == :irc -> {"irc.chat.twitch.tv", 6667}
    end
  end
end
