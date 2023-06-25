defmodule RemindlyWeb.PageController do
  use RemindlyWeb, :controller

  def landing_page(conn, _params) do
    render(conn, :landing_page)
  end

  def license(conn, _params) do
    render(conn, :license)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end
end