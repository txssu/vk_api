defmodule VkApi.Longpoll.Bot do
  alias __MODULE__

  require Logger

  def listen() do
    server_info = Bot.LongpollApi.get_server_info()

    Stream.iterate({[], server_info}, fn {_, s_info} ->
      with {:ok, {ts, updates}} <- Bot.LongpollApi.wait(s_info),
           {server, key, _} = s_info do
        {updates, {server, key, ts}}
      else
        err ->
          Logger.error(err)
          {[], Bot.LongpollApi.get_server_info()}
      end
    end)
  end
end
