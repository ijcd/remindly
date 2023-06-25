defmodule PetalProWeb.UserForgotPasswordLive do
  use PetalProWeb, :live_view

  alias PetalPro.Accounts

  def render(assigns) do
    ~H"""
    <.auth_layout title={gettext("Forgot your password?")}>
      <:logo>
        <.logo_icon class="w-20 h-20" />
      </:logo>

      <.form :let={f} id="reset_password_form" for={%{}} as={:user} phx-submit="send_email">
        <.form_field
          type="email_input"
          form={f}
          field={:email}
          required
          placeholder={gettext("eg. sarah@gmail.com")}
          autocomplete="username"
        />

        <.button
          label={gettext("Send instructions to reset password")}
          phx-disable-with={gettext("Sending...")}
          class="w-full"
        />
      </.form>

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

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/auth/reset-password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
