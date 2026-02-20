defmodule Devvy.TemplateStore do
  @moduledoc """
  File-based template resolution. Replaces CuratorWeb.Utils.get_page/2.
  Resolves templates from sites/{site}/templates/.
  """

  @doc """
  Get a template's content by permalink.
  Tries exact match first, then with underscore prefix.
  """
  def get_page(site_path, permalink) do
    templates_dir = Path.join(site_path, "templates")

    cond do
      # Exact match: templates/{permalink}.liquid
      File.exists?(Path.join(templates_dir, "#{permalink}.liquid")) ->
        {:ok, File.read!(Path.join(templates_dir, "#{permalink}.liquid"))}

      # With underscore prefix: templates/_{permalink}.liquid
      File.exists?(Path.join(templates_dir, "_#{permalink}.liquid")) ->
        {:ok, File.read!(Path.join(templates_dir, "_#{permalink}.liquid"))}

      # Without underscore if it was passed with one
      String.starts_with?(permalink, "_") &&
          File.exists?(Path.join(templates_dir, "#{permalink}.liquid")) ->
        {:ok, File.read!(Path.join(templates_dir, "#{permalink}.liquid"))}

      true ->
        {:error, :not_found}
    end
  end

  @doc """
  List all templates for a site.
  Returns list of %{name: "homepage", path: "...", permalink: "homepage"}.
  """
  def list_templates(site_path) do
    templates_dir = Path.join(site_path, "templates")

    if File.dir?(templates_dir) do
      templates_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".liquid"))
      |> Enum.sort()
      |> Enum.map(fn filename ->
        permalink = String.replace_suffix(filename, ".liquid", "")
        %{
          name: permalink,
          filename: filename,
          path: Path.join(templates_dir, filename),
          permalink: permalink
        }
      end)
    else
      []
    end
  end

  @doc """
  Get the layout template content.
  """
  def get_layout(site_path) do
    case get_page(site_path, "layout") do
      {:ok, content} -> content
      {:error, _} -> "{{body}}"
    end
  end

  @doc """
  List all site directories.
  """
  def list_sites(sites_root) do
    if File.dir?(sites_root) do
      sites_root
      |> File.ls!()
      |> Enum.filter(fn name ->
        File.dir?(Path.join(sites_root, name)) && !String.starts_with?(name, ".")
      end)
      |> Enum.sort()
      |> Enum.map(fn name ->
        site_path = Path.join(sites_root, name)
        site_json = Path.join(site_path, "site.json")

        site_data =
          if File.exists?(site_json) do
            case Jason.decode(File.read!(site_json)) do
              {:ok, data} -> data
              _ -> %{}
            end
          else
            %{}
          end

        %{
          name: name,
          path: site_path,
          display_name: site_data["name"] || name,
          description: site_data["description"] || "",
          template_count: length(list_templates(site_path))
        }
      end)
    else
      []
    end
  end
end
