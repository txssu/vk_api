defmodule VkApi.Longpoll do
  alias __MODULE__, as: Longpoll

  defdelegate get_server_info(sesion), to: Longpoll.Api, as: :get_server_info

  defdelegate wait(sesion, server_info), to: Longpoll.Api, as: :wait

  defdelegate listen(sesion), to: Longpoll.Api, as: :listen

end
