defmodule MastodonLocalTimeline do
  def start do
    host = hostname()
    access_token = access_token()
    start(host, access_token)
  end

  def start(host, access_token) do
    path = request_path(access_token)
    Socket.Web.connect!(host, path: path, secure: true) |> recv
  end

  defp env(key) do
    Application.get_env(:mastodon_local_timeline, key)
  end

  defp hostname do
    env(:host)
  end

  defp access_token do
    env(:access_token)
  end

  defp request_path(access_token) do
    path = "/api/v1/streaming/"
    query = request_query(access_token) |> URI.encode_query
    [path, query] |> Enum.join("?")
  end

  defp request_query(access_token) do
    %{
      access_token: access_token,
      stream: "public:local"
    }
  end

  defp recv(socket) do
    case socket |> Socket.Web.recv! do
      {:text, json} -> json |> handle_json
      {:ping, message} -> socket |> Socket.Web.send!({:pong, message})
    end

    recv(socket)
  end

  defp handle_json(json) do
    case JSON.decode(json) do
      {:ok, decoded} -> handle_update_event(decoded)
      _ -> IO.puts "******** failed to decode JSON ********"
    end
  end

  defp handle_update_event(%{"event" => "update", "payload" => payload}) do
    case JSON.decode(payload) do
      {:ok, message} -> message |> format_message |> IO.puts
      _ -> IO.puts "******** failed to decode payload ********"
    end
  end

  defp handle_update_event(_) do
    # just ignore
  end

  defp format_message(message) do
    account = account_info(message)
    content = content_text(message)
    "#{account}: #{content}"
  end

  defp account_info(%{"account" => %{"display_name" => display_name, "username" => username}}) do
    "#{display_name} [#{username}]"
  end

  defp content_text(%{"content" => content}) do
    content
  end
end
