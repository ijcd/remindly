defmodule RemindlyWeb.UserSignInLive do
  use RemindlyWeb, :live_view

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)

    {:ok, assign(socket, email: email, page_title: gettext("Sign in")),
     temporary_assigns: [email: nil]}
  end

  def render(assigns) do
    ~H"""
    <.auth_layout title="Sign in">
      <:logo>
        <.logo_icon class="w-20 h-20" />
      </:logo>
      <:top_links>
        <%= gettext("Not yet registered?") %>
        <.link class="text-blue-600 underline dark:text-blue-400" navigate={~p"/auth/register"}>
          <%= gettext("Register") %>
        </.link>
      </:top_links>
      <.auth_providers or_location="bottom" conn_or_socket={@socket} />

      <.form
        :let={f}
        for={%{}}
        as={:user}
        phx-update="ignore"
        id="sign_in_form"
        action={~p"/auth/sign-in"}
      >
        <.form_field
          type="text_input"
          form={f}
          field={:email}
          placeholder={gettext("eg. sarah@gmail.com")}
          autocomplete="username"
        />
        <.form_field type="password_input" form={f} field={:password} autocomplete="current-password" />
        <.form_field type="checkbox" form={f} field={:remember_me} />

        <div class="flex justify-end mt-6">
          <.button label={gettext("Sign in")} phx-disable-with={gettext("Signing in...")} />
        </div>
      </.form>
      <:bottom_links>
        <.link
          class="text-sm text-gray-500 underline dark:text-gray-400"
          href={~p"/auth/reset-password"}
        >
          <%= gettext("Forgot your password?") %>
        </.link>
      </:bottom_links>
    </.auth_layout>
    """
  end
end
