defmodule VKAPI.Longpoll.Model do
  defstruct mode: 0, need_pts: 0

  alias VKAPI.Longpoll

  @type t :: %Longpoll.Model{
          mode: integer(),
          need_pts: 0 | 1
        }

  @spec need_pts(t) :: t
  def need_pts(model = %Longpoll.Model{}), do: Map.put(model, :need_pts, 1)

  @spec set_mode(t, any) :: t
  def set_mode(model = %Longpoll.Model{}, value) do
    Map.update(model, :mode, 0, &(&1 + value))
  end

  @spec attachments_mode(t) :: t
  def attachments_mode(model = %Longpoll.Model{}), do: set_mode(model, 2)

  @spec extended_set_of_events_mode(t) :: t
  def extended_set_of_events_mode(model = %Longpoll.Model{}), do: set_mode(model, 8)

  @spec pts_mode(t) :: t
  def pts_mode(model = %Longpoll.Model{}), do: set_mode(model, 32)

  @spec online_extra_mode(t) :: t
  def online_extra_mode(model = %Longpoll.Model{}), do: set_mode(model, 64)

  @spec random_id_mode(t) :: t
  def random_id_mode(model = %Longpoll.Model{}), do: set_mode(model, 128)
end
