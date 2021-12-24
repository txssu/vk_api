defmodule VkApi.Longpoll.Bot.LongpollApi do

  @type t :: {String.t(), String.t(), String.t()}

  defp group_id do
    with {:ok, body} <- VkApi.Api.act("groups.getById") do
      body
      |> List.first()
      |> Map.fetch!("id")
    else
      _ -> 0
    end
  end

  defp request_url(server_info)

  defp request_url({server, key, ts}) do
    params = %{
      "act" => "a_check",
      "key" => key,
      "ts" => ts,
      "wait" => 25
    }

    server
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  @spec get_server_info :: t | {:error, map}
  def get_server_info() do
    with {:ok, body} <- VkApi.Api.act("groups.getLongPollServer", %{"group_id" => group_id()}),
         %{"server" => s, "key" => k, "ts" => ts} <- body do
      {s, k, ts}
    else
      err -> err
    end
  end

  @spec wait(t) :: {:ok, tuple} | {:error, any}
  def wait(server_info)

  def wait(server_info = {_server, _key, _ts}) do
    request_url(server_info)
    |> VkApi.HTTPClient.request(recv_timeout: :infinity)
    |> parse_response()
  end

  defp parse_response(response)

  defp parse_response(response = {:error, _e}), do: response

  defp parse_response({:ok, %{"failed" => err_code}}), do: {:error, err_code}

  defp parse_response({:ok, %{"ts" => ts, "updates" => updates}}) do
    {:ok, {ts, updates}}
  end
end
