defmodule RemindlyWeb.ReminderLive.Show do
  use RemindlyWeb, :live_view

  alias Remindly.Reminders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:reminder, Reminders.get_reminder!(id))}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/reminders/#{socket.assigns.reminder}")}
  end

  defp page_title(:show), do: "Show Reminder"
  defp page_title(:edit), do: "Edit Reminder"
end
