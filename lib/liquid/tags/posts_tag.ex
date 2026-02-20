defmodule Devvy.Liquid.Tags.PostsTag do
  @moduledoc """
  Port of CuratorPostsTag — filters in-memory posts list instead of DB queries.
  Usage: {% posts type:"blog", limit:5, name:"articles" %}
  """
  import Devvy.Liquid.Utils

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    markup = parse_markup(tag.markup)

    limit = to_int(extract_option(context, markup, "limit") || "10") || 10
    type = extract_option(context, markup, "type")
    subtype = extract_option(context, markup, "subtype")
    tag_filter = extract_option(context, markup, "tag")
    name = extract_option(context, markup, "name") || "posts"
    search = extract_option(context, markup, "search")
    order = extract_option(context, markup, "order") || "pubdate"
    one = extract_option(context, markup, "one") || false
    status = extract_option(context, markup, "status")
    page = to_int(extract_option(context, markup, "page") || "1") || 1
    s_permalink = extract_option(context, markup, "permalink")
    s_zid = extract_option(context, markup, "zid")
    s_parent_zid = extract_option(context, markup, "parent_zid")
    s_created_by = extract_option(context, markup, "created_by")

    # Get all posts from context
    all_posts = get_liquid_value(context, "all_posts") || []

    # Filter by status
    posts =
      case status do
        "all" -> all_posts
        "unpublished" -> Enum.filter(all_posts, fn p -> !p["pubdate"] end)
        _ -> Enum.filter(all_posts, fn p -> p["pubdate"] end)
      end

    # Filter by type
    posts =
      if type && String.length(type) >= 2 do
        if String.contains?(type, ",") do
          types = type |> String.split(",") |> Enum.map(&(String.downcase(String.trim(&1))))
          Enum.filter(posts, fn p -> String.downcase(p["type"] || "") in types end)
        else
          Enum.filter(posts, fn p -> p["type"] == type end)
        end
      else
        posts
      end

    # Filter by subtype
    posts = if subtype, do: Enum.filter(posts, fn p -> p["subtype"] == subtype end), else: posts

    # Filter by tag
    posts =
      if tag_filter do
        Enum.filter(posts, fn p ->
          tags = p["tags"] || ""
          tags_str = if is_list(tags), do: Enum.join(tags, ","), else: tags
          String.contains?(String.downcase(tags_str), String.downcase(tag_filter))
        end)
      else
        posts
      end

    # Filter by specific fields
    posts = if s_permalink, do: Enum.filter(posts, fn p -> p["permalink"] == s_permalink end), else: posts
    posts = if s_zid, do: Enum.filter(posts, fn p -> p["zid"] == s_zid end), else: posts
    posts = if s_parent_zid, do: Enum.filter(posts, fn p -> p["parent_zid"] == s_parent_zid end), else: posts
    posts = if s_created_by, do: Enum.filter(posts, fn p -> to_string(p["created_by"]) == to_string(s_created_by) end), else: posts

    # Search
    posts =
      if search && String.length(search) > 2 do
        query = String.downcase(search)
        Enum.filter(posts, fn p ->
          title = String.downcase(p["title"] || "")
          content = String.downcase(p["content"] || "")
          desc = String.downcase(p["description"] || "")
          String.contains?(title, query) || String.contains?(content, query) || String.contains?(desc, query)
        end)
      else
        posts
      end

    # Sort
    posts = sort_posts(posts, order)

    # Paginate
    total = length(posts)
    total_pages = max(1, ceil(total / limit))
    page = min(page, total_pages)
    offset = (page - 1) * limit
    paginated = posts |> Enum.drop(offset) |> Enum.take(limit)

    # Apply to context
    assigns =
      if one do
        Map.put(context.assigns, name, List.first(paginated))
      else
        context.assigns
        |> Map.put(name, paginated)
        |> Map.put("#{name}_page_number", page)
        |> Map.put("#{name}_page_size", limit)
        |> Map.put("#{name}_total_pages", total_pages)
        |> Map.put("#{name}_total_entries", total)
      end

    context = Map.put(context, :assigns, assigns)
    {output, context}
  end

  defp sort_posts(posts, order) do
    case order do
      "popular" -> Enum.sort_by(posts, fn p -> p["views"] || 0 end, :desc)
      "updated" -> Enum.sort_by(posts, fn p -> p["updated_at"] || "" end, :desc)
      "oldest" -> Enum.sort_by(posts, fn p -> p["inserted_at"] || "" end, :asc)
      "alpha" -> Enum.sort_by(posts, fn p -> String.downcase(p["title"] || "") end, :asc)
      "newest" -> Enum.sort_by(posts, fn p -> p["inserted_at"] || "" end, :desc)
      "subtype" -> Enum.sort_by(posts, fn p -> p["subtype"] || "" end, :asc)
      "type" -> Enum.sort_by(posts, fn p -> p["type"] || "" end, :asc)
      "pubdate" -> Enum.sort_by(posts, fn p -> p["pubdate"] || "" end, :desc)
      "random" -> Enum.shuffle(posts)
      "rand" -> Enum.shuffle(posts)
      _ -> Enum.sort_by(posts, fn p -> p["pubdate"] || "" end, :desc)
    end
  end
end
