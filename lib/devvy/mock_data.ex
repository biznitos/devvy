defmodule Devvy.MockData do
  @moduledoc """
  Loads JSON fixtures and builds the Liquid context map.
  Mirrors CuratorWeb.Page.assemble_vars/1.
  """

  @doc """
  Build the full Liquid template context from JSON fixtures.
  """
  def build_context(site_path, request_path, params \\ %{}) do
    site = load_json(site_path, "site.json") || %{}
    posts = load_json(site_path, "data/posts.json") || []
    users = load_json(site_path, "data/users.json") || []
    leads = load_json(site_path, "data/leads.json") || []

    # Normalize request path
    request_path = normalize_path(request_path)

    # Match post by permalink from request_path
    post = Enum.find(posts, fn p -> p["permalink"] == request_path end)

    # Build categories
    categories = Enum.filter(posts, fn p -> p["type"] == "category" end)

    # Published posts only (have pubdate)
    published_posts = Enum.filter(posts, fn p -> p["pubdate"] end)

    now = DateTime.utc_now()

    %{
      "site" => site,
      "site_url" => "http://localhost:3000",
      "current_url" => "http://localhost:3000#{request_path}",
      "path_info" => request_path,
      "locale" => site["locale"] || "en",
      "time" => DateTime.to_iso8601(now),
      "year" => "#{Date.utc_today().year}",
      "hour" => now.hour,
      "params" => params,
      "cookies" => %{},
      "env" => %{
        "host" => "localhost",
        "method" => "GET",
        "port" => 4000,
        "scheme" => "http"
      },
      "post" => post,
      "posts" => published_posts,
      "categories" => categories,
      "all_posts" => posts,
      "all_users" => users,
      "all_leads" => leads,
      "meta_title" => derive_meta_title(site, post),
      "meta_description" => derive_meta_description(site, post),
      "content_type" => "text/html",
      "api_url" => "http://localhost:3000",
      "geo" => %{},
      "ip_address" => "127.0.0.1",
      "tags" => [],
      "accepted_locales" => [%{"locale" => "en", "url" => "/"}],
      # Internal: pass site_path so partials can resolve
      "_site_path" => site_path
    }
  end

  defp normalize_path("/"), do: "/"
  defp normalize_path(path) do
    path
    |> String.trim_trailing("/")
    |> then(fn p -> if String.starts_with?(p, "/"), do: p, else: "/#{p}" end)
  end

  defp derive_meta_title(site, nil), do: site["name"] || "Devvy Site"
  defp derive_meta_title(site, post) do
    "#{post["title"]} | #{site["name"]}"
  end

  defp derive_meta_description(site, nil), do: site["description"] || ""
  defp derive_meta_description(_site, post) do
    post["description"] || ""
  end

  @doc """
  Load and parse a JSON file relative to site_path.
  Returns nil if file doesn't exist or can't be parsed.
  """
  def load_json(site_path, relative_path) do
    full_path = Path.join(site_path, relative_path)

    if File.exists?(full_path) do
      case Jason.decode(File.read!(full_path)) do
        {:ok, data} -> data
        {:error, _} -> nil
      end
    else
      nil
    end
  end
end
