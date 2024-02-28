require Logger

defmodule Servy.Plugins do
  alias Servy.Conv

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split()

    %Conv{method: method, path: path, resp_body: "", status: nil}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %Conv{conv | path: "/wildthing"}
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv) do
    Logger.debug(conv)
    conv
  end

  def track(%Conv{path: 404} = conv) do
    Logger.warning(conv)
  end

  def track(conv), do: conv
end
