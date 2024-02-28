defmodule Servy.Handler do
  @moduledoc """
  Handles Http Request
  """

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv

  @doc "Orcastation funtion"
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
  end

  @pages_path Path.expand("../pages", __DIR__)
  def serve_static(page, conv) do
    @pages_path
    |> Path.join(page <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/wildthing"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    serve_static("form", conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    serve_static(page, conv)
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    serve_static("about", conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "Not found: #{path}", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status()}
    Content-Type: text/html
    Content-length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
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

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept */*
"""

Servy.Handler.handle(request) |> IO.puts()
