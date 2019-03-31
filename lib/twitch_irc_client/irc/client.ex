defmodule TwitchIrcClient.Irc.Client do
  require Logger
  use Connection

  alias TwitchIrcClient.Irc.Config
  alias TwitchIrcClient.Irc.State

  def start_link(%Config{} = config) do
    Connection.start_link(__MODULE__, config)
  end

  def init(%Config{type: :irc} = config) do
    {:connect, :init, State.new(config)}
  end

  def send(conn, message) do
    Connection.call(conn, {:send, "#{message}\r\n"})
  end

  def connect(_, %State{config: %Config{host: host, port: port, timeout: timeout}} = state) do
    case :gen_tcp.connect(String.to_charlist(host), port, [
           :list,
           {:active, true},
           {:packet, :line},
           {:keepalive, true},
           {:send_timeout, timeout}
         ]) do
      {:ok, socket} ->
        state = State.set_socket(state, socket)

        with :ok <- login_user(state) do
          {:ok, state}
        else
          {:error, _error} -> {:backoff, 1000, state}
        end
    end
  end

  def disconnect(info, %State{socket: nil} = state) do
    case info do
      {:close, from} ->
        Connection.reply(from, :ok)

      {:error, :closed} ->
        Logger.error("Connection closed")

      {:error, reason} ->
        reason = :inet.format_error(reason)
        Logger.error("Connection error: #{reason}")
    end

    {:connect, :reconnect, State.set_socket(state, nil)}
  end

  def disconnect(info, %State{socket: socket} = state) do
    :ok = :gen_tcp.close(socket)

    case info do
      {:close, from} ->
        Connection.reply(from, :ok)

      {:error, :closed} ->
        Logger.error("Connection closed")

      {:error, reason} ->
        reason = :inet.format_error(reason)
        Logger.error("Connection error: #{reason}")
    end

    {:connect, :reconnect, State.set_socket(state, nil)}
  end

  def handle_call({:send, message}, _, %State{socket: socket} = state) do
    case :gen_tcp.send(socket, message) do
      :ok ->
        {:reply, :ok, state}

      {:error, _} = error ->
        {:disconnect, error, error, state}
    end
  end

  def handle_info({:tcp_closed, _}, %State{} = state) do
    {:disconnect, {:error, :closed}, state}
  end

  def handle_info({:tcp_error, _, error}, %State{} = state) do
    {:disconnect, {:error, error}, state}
  end

  def handle_info({:tcp, _, data}, %State{} = state) do
    Logger.info(data)
    {:noreply, state}
  end

  def handle_info({_, :badarg}, %State{} = state) do
    {:connect, :reconnect, State.set_socket(state, nil)}
  end

  defp gen_anonymous_user() do
    "justinfan#{:rand.uniform(5000)}"
  end

  defp login_user(%State{socket: socket, config: %Config{nick: :anonymous}}) do
    with :ok <- :gen_tcp.send(socket, "NICK #{gen_anonymous_user()}\r\n") do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp login_user(%State{socket: socket, config: %Config{nick: nick, oauth_token: oauth_token}}) do
    with :ok <- :gen_tcp.send(socket, "PASS oauth:#{oauth_token}\r\n"),
         :ok <- :gen_tcp.send(socket, "NICK #{nick}\r\n") do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end
end
