defmodule Devvy.Liquid.Tags.PartialTag do
  @moduledoc """
  Port of CuratorPartialTag — resolves partials from filesystem.
  Usage: {% partial "_seo" %}
  """

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    permalink =
      tag.markup
      |> String.trim()
      |> String.downcase()
      |> String.replace(["\"", "'"], "")
      |> String.trim()

    site_path = context.assigns["_site_path"] || ""

    html =
      case Devvy.TemplateStore.get_page(site_path, permalink) do
        {:ok, content} ->
          content
          |> Liquid.Template.parse()
          |> Liquid.Template.render(context)
          |> elem(1)

        {:error, _} ->
          "<!-- partial not found: #{permalink} -->"
      end

    html =
      (html || "")
      |> String.replace(~r/[\r\n]+/, "\n")
      |> String.trim()

    {[html] ++ output, context}
  end
end
