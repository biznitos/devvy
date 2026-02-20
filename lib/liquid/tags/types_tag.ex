defmodule Devvy.Liquid.Tags.TypesTag do
  @moduledoc """
  Port of CuratorTypesTag — derives type/subtype counts from posts.
  Usage: {% types type:"category", name:"my_types" %}
  """
  import Devvy.Liquid.Utils

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    markup = parse_markup(tag.markup)

    type = extract_option(context, markup, "type")
    subtype = extract_option(context, markup, "subtype")
    name = extract_option(context, markup, "name") || "types"

    all_posts = get_liquid_value(context, "all_posts") || []

    # Filter to published posts
    posts = Enum.filter(all_posts, fn p -> p["pubdate"] end)

    # Filter by type/subtype if specified
    posts = if type, do: Enum.filter(posts, fn p -> Regex.match?(~r/#{type}/i, p["type"] || "") end), else: posts
    posts = if subtype, do: Enum.filter(posts, fn p -> Regex.match?(~r/#{subtype}/i, p["subtype"] || "") end), else: posts

    # Group by type + subtype
    types =
      posts
      |> Enum.group_by(fn p -> {p["type"], p["subtype"]} end)
      |> Enum.map(fn {{t, st}, items} ->
        %{"type" => t, "subtype" => st, "count" => length(items)}
      end)
      |> Enum.sort_by(fn t -> {String.downcase(t["type"] || ""), String.downcase(t["subtype"] || "")} end)

    assigns = Map.put(context.assigns, name, types)
    context = Map.put(context, :assigns, assigns)

    {output, context}
  end
end
