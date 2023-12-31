defmodule RemindlyWeb.EditPasswordLive do
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
    <.settings_layout current_page={:edit_password} current_user={@current_user}>
      <.form :let={f} for={@changeset} action={~p"/app/users/settings/update-password"}>
        <.form_field
          type="password_input"
          form={f}
          field={:current_password}
          name="current_password"
          label={gettext("Current password")}
          autocomplete="current-password"
        />

        <.form_field
          type="password_input"
          form={f}
          field={:password}
          label={gettext("New password")}
          autocomplete="new-password"
        />

        <.form_field
          type="password_input"
          form={f}
          field={:password_confirmation}
          label={gettext("New password confirmation")}
          autocomplete="new-password"
        />

        <div class="flex justify-between">
          <button
            type="button"
            phx-click="send_password_reset_email"
            data-confirm={
              gettext("This will send a reset password link to the email '%{email}'. Continue?",
                email: @current_user.email
              )
            }
            class="text-sm text-gray-500 underline dark:text-gray-400"
          >
            <%= gettext("Forgot your password?") %>
          </button>

          <.button><%= gettext("Change password") %></.button>
        </div>
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("send_password_reset_email", _, socket) do
    Accounts.deliver_user_reset_password_instructions(
      socket.assigns.current_user,
      &url(~p"/auth/reset-password/#{&1}")
    )

    {:noreply,
     put_flash(
       socket,
       :info,
       gettext("You will receive instructions to reset your password shortly.")
     )}
  end
end
