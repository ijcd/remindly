defmodule RemindlyWeb.EditEmailLive do
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
    <.settings_layout current_page={:edit_email} current_user={@current_user}>
      <.form :let={f} id="change_email_form" for={@changeset} phx-submit="update_email">
        <.form_field
          type="email_input"
          form={f}
          field={:email}
          label={gettext("Change your email")}
          placeholder={gettext("eg. john@gmail.com")}
          autocomplete="username"
        />

        <div class="flex justify-end">
          <.button><%= gettext("Change email") %></.button>
        </div>
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    current_user = socket.assigns.current_user

    case Accounts.check_if_can_change_user_email(current_user, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          current_user.email,
          &url(~p"/app/users/settings/confirm-email/#{&1}")
        )

        Accounts.user_lifecycle_action("request_new_email", current_user, %{
          new_email: user_params["email"]
        })

        {:noreply,
         put_flash(
           socket,
           :info,
           gettext("A link to confirm your e-mail change has been sent to the new address.")
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, %{changeset: changeset})}
    end
  end
end
