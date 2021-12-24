defmodule VkApi.Api do
  @base_url URI.parse("https://api.vk.com/method/")
  @token Application.fetch_env!(:vk_api, :token)
  @v Application.fetch_env!(:vk_api, :version)

  @spec request_url(String.t(), Enum.t()) :: Strint.t()
  defp request_url(method, params) do
    @base_url
    |> URI.merge(method)
    |> Map.put(:query, URI.encode_query(params))
    |> URI.to_string()
  end

  @spec act(binary, map) :: {:ok, map | list} | {:error, map}
  def act(method, params \\ %{}) do
    params =
      params
      |> Map.put("access_token", @token)
      |> Map.put("v", @v)

    request_url(method, params)
    |> VkApi.HTTPClient.request()
    |> parse_response()
  end

  defp parse_response(response)

  defp parse_response(response = {:error, _e}), do: response

  defp parse_response({:ok, body}) do
    case body do
      %{"response" => res} -> {:ok, res}
      %{"error" => err} -> {:error, err}
    end
  end
end
