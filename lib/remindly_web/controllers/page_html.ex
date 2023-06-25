defmodule RemindlyWeb.PageHTML do
  use RemindlyWeb, :html
  alias RemindlyWeb.Components.LandingPage

  embed_templates "page_html/*"
end
