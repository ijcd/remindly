defmodule RemindlyWeb.EditProfileLive do
  use RemindlyWeb, :live_view
  import RemindlyWeb.UserSettingsLayoutComponent
  alias Remindly.Accounts
  alias Remindly.Accounts.User

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       changeset: User.profile_changeset(socket.assigns.current_user)
     )}
  end

  def render(assigns) do
    ~H"""
    <.settings_layout current_page={:edit_profile} current_user={@current_user}>
      <.form :let={f} id="update_profile_form" for={@changeset} phx-submit="update_profile">
        <.form_field
          type="text_input"
          form={f}
          field={:name}
          label={gettext("Name")}
          placeholder={gettext("eg. John Smith")}
        />

        <div class="flex justify-end">
          <.button><%= gettext("Update profile") %></.button>
        </div>
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    case Accounts.update_profile(socket.assigns.current_user, user_params) do
      {:ok, current_user} ->
        Accounts.user_lifecycle_action("after_update_profile", current_user)

        socket =
          socket
          |> put_flash(:info, gettext("Profile updated"))
          |> assign(current_user: current_user, changeset: User.profile_changeset(current_user))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> put_flash(:error, gettext("Update failed. Please check the form for issues"))
          |> assign(changeset: changeset)

        {:noreply, socket}
    end
  end
end
