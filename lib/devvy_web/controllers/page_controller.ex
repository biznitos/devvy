defmodule DevvyWeb.PageController do
  use DevvyWeb, :controller

  defp sites_root do
    Path.join(File.cwd!(), "sites")
  end

  @doc """
  Dashboard: lists all sites in sites/ directory.
  """
  def dashboard(conn, _params) do
    sites = Devvy.TemplateStore.list_sites(sites_root())
    current_site = get_current_site(conn)

    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Devvy — Site Dashboard</title>
      <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 min-h-screen">
      <div class="max-w-4xl mx-auto px-4 py-12">
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Devvy</h1>
          <p class="mt-2 text-gray-600">Curator Website Development Environment</p>
          #{if current_site, do: "<p class=\"mt-1 text-sm text-blue-600\">Active site: <strong>#{current_site}</strong></p>", else: ""}
        </div>

        #{if length(sites) == 0 do
          "<div class=\"bg-white rounded-lg shadow p-8 text-center\">
            <p class=\"text-gray-500\">No sites found in <code>sites/</code> directory.</p>
            <p class=\"mt-2 text-sm text-gray-400\">Create a site with <code>/newsite sitename</code></p>
          </div>"
        else
          "<div class=\"grid gap-4\">#{Enum.map_join(sites, "\n", fn site ->
            is_active = current_site == site.name
            "<a href=\"/?site=#{site.name}\" class=\"block bg-white rounded-lg shadow hover:shadow-lg transition p-6 #{if is_active, do: "ring-2 ring-blue-500", else: ""}\">
              <div class=\"flex items-center justify-between\">
                <div>
                  <h2 class=\"text-xl font-bold text-gray-900\">#{site.display_name}</h2>
                  <p class=\"text-sm text-gray-500\">#{site.name}</p>
                  #{if site.description != "", do: "<p class=\"mt-1 text-gray-600\">#{site.description}</p>", else: ""}
                </div>
                <div class=\"text-right\">
                  <span class=\"text-sm text-gray-400\">#{site.template_count} templates</span>
                  #{if is_active, do: "<br><span class=\"text-xs text-blue-600 font-medium\">ACTIVE</span>", else: ""}
                </div>
              </div>
            </a>"
          end)}</div>"
        end}
      </div>
    </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  @doc """
  Catch-all route — renders Liquid templates via Devvy.Renderer.
  Site selected via ?site= query param (sticky via cookie).
  """
  def render_page(conn, params) do
    # Handle site switching via query param
    conn = handle_site_switch(conn, params)
    site_name = get_current_site(conn)

    if site_name == nil do
      # No site selected — show dashboard
      dashboard(conn, params)
    else
      site_path = Path.join(sites_root(), site_name)

      if !File.dir?(site_path) do
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(404, "Site '#{site_name}' not found. <a href='/devvy'>Go to dashboard</a>")
      else
        # Build request path from the catch-all path segments
        path_segments = params["path"] || []
        request_path = "/" <> Enum.join(path_segments, "/")

        # Pass query params (minus "site")
        query_params = Map.delete(params, "path") |> Map.delete("site")

        case Devvy.Renderer.render(site_path, request_path, query_params) do
          {:ok, html} ->
            conn
            |> put_resp_content_type("text/html")
            |> send_resp(200, html)

          {:error, :not_found} ->
            conn
            |> put_resp_content_type("text/html")
            |> send_resp(404, "Page not found: #{request_path}")
        end
      end
    end
  end

  # Handle ?site=xxx query param — sets cookie
  defp handle_site_switch(conn, %{"site" => site_name}) when site_name != "" do
    conn
    |> put_resp_cookie("devvy_site", site_name, max_age: 86400 * 365)
    |> fetch_cookies()
  end
  defp handle_site_switch(conn, _params), do: conn

  # Get current site from query param or cookie
  defp get_current_site(conn) do
    conn = fetch_cookies(conn)
    conn.params["site"] || conn.cookies["devvy_site"]
  end
end
