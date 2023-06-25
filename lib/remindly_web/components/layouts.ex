defmodule RemindlyWeb.Layouts do
  use RemindlyWeb, :html

  embed_templates "layouts/*"

  require Logger

  def app_name, do: Remindly.config(:app_name)

  def title(%{assigns: %{page_title: page_title}}), do: page_title

  def title(conn) do
    if is_public_page(conn.request_path) do
      Logger.warning(
        "Warning: no title defined for path #{conn.request_path}. Defaulting to #{app_name()}. Assign `page_title` in controller action or live view mount to fix."
      )
    end

    app_name()
  end

  def description(%{assigns: %{meta_description: meta_description}}), do: meta_description

  def description(conn) do
    if conn.request_path == "/" do
      Remindly.config(:seo_description)
    else
      if is_public_page(conn.request_path) do
        Logger.warning(
          "Warning: no meta description for public path #{conn.request_path}. Assign `meta_description` in controller action or live view mount to fix."
        )
      end

      ""
    end
  end

  def og_image(%{assigns: %{og_image: og_image}}), do: og_image
  def og_image(_conn), do: url(~p"/assets/images/open-graph.png")

  def current_page_url(%{request_path: request_path}),
    do: RemindlyWeb.Endpoint.url() <> request_path

  def current_page_url(_conn), do: RemindlyWeb.Endpoint.url()

  def twitter_creator(%{assigns: %{twitter_creator: twitter_creator}}), do: twitter_creator
  def twitter_creator(_conn), do: twitter_site(%{})

  def twitter_site(%{assigns: %{twitter_site: twitter_site}}), do: twitter_site

  def twitter_site(_conn) do
    if Remindly.config(:twitter_url) do
      "@" <> (Remindly.config(:twitter_url) |> String.split("/") |> List.last())
    else
      ""
    end
  end

  def is_public_page(request_path) do
    request_path != "/" &&
      RemindlyWeb.Menus.public_menu_items()
      |> Enum.map(& &1.path)
      |> Enum.find(&(&1 == request_path))
  end
end
