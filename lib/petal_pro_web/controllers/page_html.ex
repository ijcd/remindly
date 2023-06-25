defmodule PetalProWeb.PageHTML do
  use PetalProWeb, :html
  alias PetalProWeb.Components.LandingPage

  embed_templates "page_html/*"
end
