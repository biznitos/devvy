defmodule Devvy.Liquid.Tags.UsersTag do
  @moduledoc """
  Port of CuratorUsersTag — filters in-memory users list.
  Usage: {% users role:"admin", limit:5 %}
  """
  import Devvy.Liquid.Utils

  def parse(%Liquid.Tag{} = tag, %Liquid.Template{} = context) do
    {tag, context}
  end

  def render(output, tag, context) do
    markup = parse_markup(tag.markup)

    limit = to_int(extract_option(context, markup, "limit") || "10") || 10
    role = extract_option(context, markup, "role")
    search = extract_option(context, markup, "search")
    one = extract_option(context, markup, "one") || false
    order = extract_option(context, markup, "order") || "newest"
    name = extract_option(context, markup, "name") || "members"
    page = to_int(extract_option(context, markup, "page") || "1") || 1

    all_users = get_liquid_value(context, "all_users") || []

    members = all_users

    # Filter by role
    members =
      if role do
        Enum.filter(members, fn u -> u["role"] == role end)
      else
        members
      end

    # Search
    members =
      if search && String.length(String.trim(search)) > 2 do
        q = String.downcase(search)
        Enum.filter(members, fn u ->
          username = String.downcase(u["username"] || "")
          user_name = String.downcase(get_in(u, ["user", "name"]) || "")
          String.contains?(username, q) || String.contains?(user_name, q)
        end)
      else
        members
      end

    # Sort
    members =
      case order do
        "updated" -> Enum.sort_by(members, fn u -> u["updated_at"] || "" end, :desc)
        _ -> Enum.sort_by(members, fn u -> u["inserted_at"] || "" end, :desc)
      end

    # Paginate
    total = length(members)
    total_pages = max(1, ceil(total / limit))
    paginated = members |> Enum.drop((page - 1) * limit) |> Enum.take(limit)

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
end
