defmodule Servy.FileHandler do
  def handle_file(file, conv) do
    case file do
      {:ok, content} -> %{conv | resp_body: content, status: 200}
      {:error, :enoent} -> %{conv | resp_body: "File Not Found.", status: 404}
      {:error, reason} -> %{conv | resp_body: "File Error: #{reason}", status: 500}
    end
  end
end
