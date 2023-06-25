defmodule PetalProWeb.DevDashboardLive do
  use PetalProWeb, :live_view
  alias PetalProWeb.DevLayoutComponent

  def render(assigns) do
    ~H"""
    <DevLayoutComponent.dev_layout current_page={:dev} current_user={@current_user}>
      <.container class="py-16">
        <div class="ml-[60px]">
          <.h2><%= PetalPro.config(:app_name) %></.h2>
          <.p>A list of your apps routes. Click one to copy its helper.</.p>
        </div>
        <.route_tree router={PetalProWeb.Router} />
      </.container>
    </DevLayoutComponent.dev_layout>
    """
  end
end
