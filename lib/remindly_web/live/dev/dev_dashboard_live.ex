defmodule RemindlyWeb.DevDashboardLive do
  use RemindlyWeb, :live_view
  alias RemindlyWeb.DevLayoutComponent

  def render(assigns) do
    ~H"""
    <DevLayoutComponent.dev_layout current_page={:dev} current_user={@current_user}>
      <.container class="py-16">
        <div class="ml-[60px]">
          <.h2><%= Remindly.config(:app_name) %></.h2>
          <.p>A list of your apps routes. Click one to copy its helper.</.p>
        </div>
        <.route_tree router={RemindlyWeb.Router} />
      </.container>
    </DevLayoutComponent.dev_layout>
    """
  end
end
