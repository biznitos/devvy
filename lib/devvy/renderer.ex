defmodule Devvy.Renderer do
  @moduledoc """
  Core rendering pipeline mirroring CuratorWeb.Page.render_page/1.
  Resolves templates, renders Liquid, wraps in layout.
  """

  alias Devvy.{TemplateStore, MockData}

  @doc """
  Render a page for the given site and request path.
  Returns {:ok, html} or {:error, :not_found}.
  """
  def render(site_path, request_path, params \\ %{}) do
    # 1. Build context
    vars = MockData.build_context(site_path, request_path, params)

    # 2. Resolve template
    case resolve_template(site_path, request_path, vars) do
      {:ok, template_content, vars} ->
        # 3. Render body template
        body = render_liquid(template_content, vars)

        # 4. Get layout and inject body
        layout = TemplateStore.get_layout(site_path)
        page = String.replace(layout, "{{body}}", body)

        # 5. Final render pass (catches Liquid in layout, post content, etc.)
        page = render_liquid(page, vars)

        # 6. Ensure DOCTYPE
        page =
          if !String.starts_with?(String.trim(page), "<!DOCTYPE") do
            "<!DOCTYPE html>\n#{page}"
          else
            page
          end

        {:ok, page}

      {:error, :not_found} ->
        # Try to render 404 template
        case TemplateStore.get_page(site_path, "404") do
          {:ok, content} ->
            body = render_liquid(content, vars)
            layout = TemplateStore.get_layout(site_path)
            page = String.replace(layout, "{{body}}", body)
            page = render_liquid(page, vars)
            {:ok, page}

          {:error, _} ->
            {:error, :not_found}
        end
    end
  end

  @doc """
  Resolve which template to use for a given request path.
  Returns {:ok, template_content, updated_vars} or {:error, :not_found}.
  """
  def resolve_template(site_path, request_path, vars) do
    request_path = normalize_path(request_path)
    post = vars["post"]

    cond do
      # Homepage
      request_path == "/" ->
        case TemplateStore.get_page(site_path, "homepage") do
          {:ok, content} -> {:ok, content, vars}
          {:error, _} -> {:error, :not_found}
        end

      # Post matched — find the type_single template
      post != nil ->
        type = post["type"] || "content"
        template_name = "#{type}_single"

        case TemplateStore.get_page(site_path, template_name) do
          {:ok, content} -> {:ok, content, vars}
          {:error, _} ->
            # Fallback to content_single
            case TemplateStore.get_page(site_path, "content_single") do
              {:ok, content} -> {:ok, content, vars}
              {:error, _} -> {:error, :not_found}
            end
        end

      # Try exact template match by path segments
      true ->
        # /services → "services", /blog → "blog", /contact → "contact"
        template_name =
          request_path
          |> String.trim_leading("/")
          |> String.replace("/", "_")

        case TemplateStore.get_page(site_path, template_name) do
          {:ok, content} -> {:ok, content, vars}
          {:error, _} ->
            # Try parent path for nested routes like /services/deep-cleaning
            # Check if a post matches this path
            all_posts = vars["all_posts"] || []
            matched_post = Enum.find(all_posts, fn p -> p["permalink"] == request_path end)

            if matched_post do
              updated_vars = Map.put(vars, "post", matched_post)
              type = matched_post["type"] || "content"
              template_name = "#{type}_single"

              case TemplateStore.get_page(site_path, template_name) do
                {:ok, content} -> {:ok, content, updated_vars}
                {:error, _} ->
                  case TemplateStore.get_page(site_path, "content_single") do
                    {:ok, content} -> {:ok, content, updated_vars}
                    {:error, _} -> {:error, :not_found}
                  end
              end
            else
              {:error, :not_found}
            end
        end
    end
  end

  defp render_liquid(template_content, vars) do
    try do
      template_content
      |> Liquid.Template.parse()
      |> Liquid.Template.render(vars)
      |> extract_rendered()
    rescue
      e ->
        "<!-- Liquid render error: #{Exception.message(e)} -->"
    end
  end

  defp extract_rendered({:ok, result, _context}) when is_binary(result), do: result
  defp extract_rendered({:ok, result}) when is_binary(result), do: result
  defp extract_rendered({_, result, _}) when is_binary(result), do: result
  defp extract_rendered({_, result}) when is_binary(result), do: result
  defp extract_rendered(result) when is_binary(result), do: result
  defp extract_rendered(other), do: inspect(other)

  defp normalize_path("/"), do: "/"
  defp normalize_path(path) do
    path
    |> String.trim_trailing("/")
    |> then(fn p -> if String.starts_with?(p, "/"), do: p, else: "/#{p}" end)
  end
end
