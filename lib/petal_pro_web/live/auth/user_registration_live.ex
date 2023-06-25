defmodule PetalProWeb.UserRegistrationLive do
  use PetalProWeb, :live_view

  alias PetalPro.Accounts
  alias PetalPro.Accounts.User

  def render(assigns) do
    ~H"""
    <.auth_layout title="Register">
      <:logo>
        <.logo_icon class="w-20 h-20" />
      </:logo>
      <:top_links>
        <%= gettext("Already registered?") %>
        <.link class="text-blue-600 underline" navigate={~p"/auth/sign-in"}>
          <%= gettext("Sign in") %>
        </.link>
      </:top_links>
      <.auth_providers or_location="bottom" conn_or_socket={@socket} />

      <.form
        :let={f}
        id="registration_form"
        for={@changeset}
        action={~p"/auth/sign-in?_action=registered"}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        method="post"
        as={:user}
      >
        <div :if={@changeset.action == :insert}>
          <.alert
            color="danger"
            label={gettext("Oops, something went wrong! Please check the errors below.")}
            class="mb-5"
          />
        </div>

        <.form_field
          type="text_input"
          form={f}
          field={:name}
          placeholder={gettext("eg. Sarah Smith")}
          phx-debounce="blur"
          required
        />
        <.form_field
          type="email_input"
          form={f}
          field={:email}
          placeholder={gettext("eg. sarah@gmail.com")}
          phx-debounce="blur"
          autocomplete="username"
          required
        />
        <.form_field
          type="password_input"
          phx-debounce="blur"
          form={f}
          value={Phoenix.HTML.Form.input_value(f, :password)}
          field={:password}
          autocomplete="new-password"
        />
        <div class="flex justify-end mt-6">
          <.button
            label={gettext("Create account")}
            phx-disable-with={gettext("Creating account...")}
          />
        </div>
      </.form>
    </.auth_layout>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        case Accounts.deliver_user_confirmation_instructions(
               user,
               &url(~p"/auth/confirm/#{&1}")
             ) do
          {:ok, _} ->
            changeset = Accounts.change_user_registration(user)
            {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

          {:error, _} ->
            {:noreply,
             put_flash(
               socket,
               :error,
               "User has been registered but email delivery failed. Please contact support."
             )}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end
