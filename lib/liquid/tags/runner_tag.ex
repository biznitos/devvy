defmodule Devvy.Liquid.Tags.RunnerTag do
  @moduledoc """
  Stub for {% runner %} tag — not available in dev.
  """

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    permalink = String.trim(tag.markup)
    html = "<!-- runner: #{permalink} (not available in dev) -->"
    {[html] ++ output, context}
  end
end
