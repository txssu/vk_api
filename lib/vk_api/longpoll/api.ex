defmodule VKAPI.Longpoll.Api do
  alias VKAPI.Session
  alias VKAPI.Longpoll

  @type t :: {String.t(), String.t(), String.t()}

  defp request_url({host, params}) do
    host
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  defp url_params(%Session{type: :group}, {server, key, ts}) do
    params = %{
      "act" => "a_check",
      "key" => key,
      "ts" => ts,
      "wait" => 25
    }

    {server, params}
  end

  defp url_params(%Session{type: :user, longpoll: %Longpoll.Model{mode: mode}}, {server, key, ts}) do
    params = %{
      "act" => "a_check",
      "key" => key,
      "ts" => ts,
      "wait" => 25,
      "mode" => mode
    }

    {"https://" <> server, params}
  end

  def get_server_info(session) do
    fun =
      case session do
        %Session{type: :group, id: id} = session ->
          fn ->
            VKAPI.act(session, "groups.getLongPollServer", %{"group_id" => id})
          end

        %Session{type: :user} = session ->
          VKAPI.act(session, "messages.getLongPollServer")
      end

    process_getting_server_info(fun)
  end

  defp fun_get_server_info(%Session{type: :group, id: id} = session) do
    process_getting_server_info(fn ->
      VKAPI.act(session, "groups.getLongPollServer", %{"group_id" => id})
    end)
  end

  defp fun_get_server_info(%Session{type: :user} = session) do
    process_getting_server_info(fn ->
      VKAPI.act(session, "messages.getLongPollServer")
    end)
  end

  defp process_getting_server_info(fun) do
    fn ->
      with {:ok, body} <- fun.(),
           %{"server" => server, "key" => key, "ts" => ts} = body do
        {server, key, ts}
      else
        err -> err
      end
    end
  end

  @spec wait(Session.t(), t) :: {list(map), t}
  def wait(session, server_info = {server, key, _ts}) do
    result =
      url_params(session, server_info)
      |> request_url()
      |> VKAPI.HTTPClient.request(recv_timeout: :infinity)
      |> parse_response()

    case result do
      {:ok, {ts, updates}} -> {updates, {server, key, ts}}
    end
  end

  defp parse_response(response)

  defp parse_response(response = {:error, _e}), do: response

  defp parse_response({:ok, %{"failed" => err_code}}), do: {:error, err_code}

  defp parse_response({:ok, %{"ts" => ts, "updates" => updates}}) do
    {:ok, {ts, updates}}
  end

  @spec listen(Session.t()) ::
          ({:cont, any} | {:halt, any} | {:suspend, any}, any ->
             :badarg | {:halted, any} | {:suspended, any, (any -> any)})
  def listen(session) do
    session =
      case session do
        s = %Session{longpoll: nil} -> Session.set_longpoll(s, %Longpoll.Model{})
        s -> s
      end

    Stream.resource(
      fun_get_server_info(session),
      fn server_info -> wait(session, server_info) end,
      fn _ -> nil end
    )
  end
end
