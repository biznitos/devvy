defmodule DevvyWeb.ErrorHTML do
  def render(template, _assigns) do
    "Error: #{template}"
  end
end
