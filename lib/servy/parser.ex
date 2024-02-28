defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split()

    %Conv{method: method, path: path, resp_body: "", status: nil}
  end
end
