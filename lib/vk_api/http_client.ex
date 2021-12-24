defmodule VkApi.HTTPClient do
  @spec request(String.t()) :: {:ok, map} | {:error, map}
  def request(url, options \\ []) do
    case HTTPoison.post(url, "", [], options) do
      {:ok, response} ->
        response.body
        |> Jason.decode()

      {:error, err} ->
        err
    end
  end
end
