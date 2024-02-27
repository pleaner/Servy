require Logger

defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  def parse(request) do
    [method, path, _version] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split()

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthing"}
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def rewrite_path(conv), do: conv

  def log(conv) do
    Logger.debug(conv)
    conv
  end

  def route(%{method: "GET", path: "/wildthing"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    case File.read("./lib/pages/about.html") do
      {:ok, content} -> %{conv | resp_body: content, status: 200}
      {:error, reason} -> %{conv | resp_body: "File Error", status: 404}
    end
  end

  def route(%{path: path} = conv) do
    %{conv | resp_body: "Not found: #{path}", status: 404}
  end

  def track(%{path: 404} = conv) do
    Logger.warning(conv)
  end

  def track(conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /wildthing HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()
