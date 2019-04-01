defmodule TwitchIrcClient.Irc.Channel do
  defstruct name: nil,
            badge: nil,
            emote_only: nil,
            followers_only: nil,
            r9k: nil,
            slow: nil,
            subs_only: nil,
            chat_rooms: []
end
