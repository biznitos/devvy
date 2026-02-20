defmodule DevvyWeb.Router do
  use DevvyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, false
    plug :put_secure_browser_headers
  end

  scope "/", DevvyWeb do
    pipe_through :browser

    get "/devvy", PageController, :dashboard
    get "/*path", PageController, :render_page
  end
end
