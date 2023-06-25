defmodule RemindlyWeb.UserResetPasswordLive do
  use RemindlyWeb, :live_view

  alias Remindly.Accounts

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{user: user} ->
          assign(socket, :changeset, Accounts.change_user_password(user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def render(assigns) do
    ~H"""
    <.auth_layout title={gettext("Reset password")}>
      <:logo>
        <.logo_icon class="w-20 h-20" />
      </:logo>

      <div>
        <.form
          :let={f}
          for={@changeset}
          id="reset_password_form"
          phx-submit="reset_password"
          phx-change="validate"
        >
          <.error :if={@changeset.action == :insert}>
            <%= gettext("Oops, something went wrong! Please check the errors below.") %>
          </.error>

          <.form_field
            type="password_input"
            form={f}
            field={:password}
            label={gettext("New password")}
            value={Phoenix.HTML.Form.input_value(f, :password)}
            autocomplete="new-password"
            phx-debounce="blur"
            required
          />
          <.form_field
            type="password_input"
            form={f}
            field={:password_confirmation}
            label={gettext("Confirm new password")}
            value={Phoenix.HTML.Form.input_value(f, :password_confirmation)}
            autocomplete="new-password"
            phx-debounce="blur"
            required
          />

          <div class="flex justify-end mt-6">
            <.button label={gettext("Reset password")} phx-disable-with={gettext("Resetting...")} />
          </div>
        </.form>
      </div>

      <:bottom_links>
        <div class="flex justify-center gap-3">
          <.link class="text-sm underline" href={~p"/auth/register"}>
            <%= gettext("Register") %>
          </.link>
          <.link class="text-sm underline" href={~p"/auth/sign-in"}>
            <%= gettext("Sign in") %>
          </.link>
        </div>
      </:bottom_links>
    </.auth_layout>
    """
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/auth/sign-in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end
end
