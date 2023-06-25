defmodule RemindlyWeb.ReminderLive.FormComponent do
  use RemindlyWeb, :live_component

  alias Remindly.Reminders

  @impl true
  def update(%{reminder: reminder} = assigns, socket) do
    changeset = Reminders.change_reminder(reminder)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"reminder" => reminder_params}, socket) do
    changeset =
      socket.assigns.reminder
      |> Reminders.change_reminder(reminder_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"reminder" => reminder_params}, socket) do
    save_reminder(socket, socket.assigns.action, reminder_params)
  end

  defp save_reminder(socket, :edit, reminder_params) do
    case Reminders.update_reminder(socket.assigns.reminder, reminder_params) do
      {:ok, _reminder} ->
        {:noreply,
         socket
         |> put_flash(:info, "Reminder updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_reminder(socket, :new, reminder_params) do
    reminder_params = Map.put(reminder_params, "user_id", socket.assigns.current_user.id)

    case Reminders.create_reminder(reminder_params) do
      {:ok, reminder} ->
        Remindly.Logs.log("create_reminder", %{
          user: socket.assigns.current_user,
          metadata: %{
            reminder_id: reminder.id,
            reminder_label: reminder.label
          }
        })

        {:noreply,
         socket
         |> put_flash(:info, "Reminder created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
