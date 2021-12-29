defmodule VkApi.Session do
  alias __MODULE__, as: Session

  defstruct token: "", type: nil, id: 0, longpoll: nil

  @type t :: %Session{
          token: String.t(),
          type: atom,
          longpoll: VkApi.Longpoll.Model | nil
        }

  @spec new(String.t()) :: t
  def new(token) do
    session = %Session{token: token}

    case get_type(session) do
      {:error, _err} = e -> e
      {type, id} -> session |> Map.put(:type, type) |> Map.put(:id, id)
    end
  end

  def set_longpoll(session = %Session{}, longpoll = %VkApi.Longpoll.Model{}) do
    Map.put(session, :longpoll, longpoll)
  end

  @spec get_type(VkApi.Session.t()) :: {:error, map} | {:user | :group_id, integer}
  def get_type(session = %Session{}) do
    case VkApi.act(session, "groups.getById") do
      {:error, _} ->
        case VkApi.act(session, "users.get") do
          {:error, _err} = e -> e
          {:ok, [%{"id" => id}]} -> {:user, id}
        end

      {:ok, [%{"id" => id}]} ->
        {:group, id}
    end
  end
end
