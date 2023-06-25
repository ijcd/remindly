defmodule RemindlyWeb.ReminderLive.Index do
  use RemindlyWeb, :live_view

  alias Remindly.Reminders
  alias Remindly.Reminders.Reminder
  alias PetalFramework.Components.DataTable

  @data_table_opts [
    default_limit: 10,
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    },
    sortable: [:id, :inserted_at, :label, :due_date, :is_done],
    filterable: [:id, :inserted_at, :label, :due_date, :is_done]
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, index_params: nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Reminder")
    |> assign(:reminder, Reminders.get_reminder!(id))
    |> assign(:return_to, current_index_path(socket))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Reminder")
    |> assign(:reminder, %Reminder{due_date: Timex.now() |> Timex.to_date()})
    |> assign(:return_to, current_index_path(socket))
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Reminders")
    |> assign_reminders(params)
    |> assign(index_params: params)
  end

  defp current_index_path(socket) do
    ~p"/app/reminders?#{socket.assigns[:index_params] || []}"
  end

  @impl true
  def handle_event("update_filters", params, socket) do
    query_params = DataTable.build_filter_params(socket.assigns.meta.flop, params)
    {:noreply, push_patch(socket, to: ~p"/app/reminders?#{query_params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    reminder = Reminders.get_reminder!(id)
    {:ok, _} = Reminders.delete_reminder(reminder)

    socket =
      socket
      |> assign_reminders(socket.assigns.index_params)
      |> put_flash(:info, "Reminder deleted")

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: current_index_path(socket))}
  end

  @impl true
  def handle_event("toggle_reminder", %{"id" => reminder_id}, socket) do
    reminder = Reminders.get_reminder!(reminder_id)

    case Reminders.update_reminder(reminder, %{is_done: !reminder.is_done}) do
      {:ok, reminder} ->
        if reminder.is_done do
          Remindly.Logs.log("complete_reminder", %{
            user: socket.assigns.current_user,
            metadata: %{
              reminder_id: reminder.id,
              reminder_label: reminder.label
            }
          })
        end

        {:noreply, assign_reminders(socket, socket.assigns.index_params)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Something went wrong.")}
    end
  end

  defp assign_reminders(socket, params) do
    starting_query = Ecto.assoc(socket.assigns.current_user, :reminders)
    {reminders, meta} = DataTable.search(starting_query, params, @data_table_opts)
    assign(socket, reminders: reminders, meta: meta)
  end
end
