defmodule VkApi do
  import VkApi

  @spec act(Session.t(), String.t(), map) :: {:error, map} | {:ok, list | map}
  defdelegate act(session, method, params \\ %{}), to: Request

  @spec new_session(String.t()) :: Session.t()
  defdelegate new_session(token), to: Session, as: :new
end
