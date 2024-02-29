defmodule Servy do
  def hello(name) do
    "Hello, #{name}!"
  end

  def hello() do
    :world
  end
end

# IO.puts Servy.hello("Elixir")
