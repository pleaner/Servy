defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _version] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    # headers =
    #   Enum.into(header_lines, %{}, fn line ->
    #     [k, v] = String.split(line, ": ")
    #     {k, v}
    #   end)

    params = parse_params(params_string, headers["Content-Type"])

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  defp parse_params(raw_params, "application/x-www-form-urlencoded") do
    raw_params
    |> String.trim()
    |> URI.decode_query()
  end

  defp parse_params(_, _), do: %{}

  def parse_headers([head | tail], headers) do
    [k, v] = String.split(head, ": ")
    parse_headers(tail, Map.put(headers, k, v))
  end

  def parse_headers([], headers), do: headers
end
