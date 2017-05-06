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
      {:text, json} -> json |> IO.puts
      {:ping, message} -> socket |> Socket.Web.send!({:pong, message})
    end

    recv(socket)
  end
end
