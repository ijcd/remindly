defmodule RemindlyWeb.OrgTeamLive.OrgTeamInviteFormComponent do
  use RemindlyWeb, :live_component
  alias Remindly.Accounts
  alias Remindly.Orgs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.modal max_width="sm" title={@page_title}>
        <.form
          :let={f}
          id="form-invite"
          for={@changeset}
          phx-submit="invite"
          phx-change="validate"
          phx-target={@myself}
        >
          <.form_field
            type="email_input"
            form={f}
            field={:email}
            label={gettext("Email")}
            placeholder={gettext("eg. john@gmail.com")}
            phx-debounce="blur"
          />

          <div class="flex justify-end">
            <.button phx-disable-with={gettext("Inviting...")}><%= gettext("Invite") %></.button>
          </div>
        </.form>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Orgs.Invitation.changeset(%Orgs.Invitation{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"invitation" => params}, socket) do
    changeset =
      socket.assigns.current_org
      |> Orgs.build_invitation(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("invite", %{"invitation" => params}, socket) do
    org = socket.assigns.current_org

    case Orgs.create_invitation(org, params) do
      {:ok, invitation} ->
        to =
          if invitation.user_id do
            url(~p"/app/users/org-invitations")
          else
            url(~p"/auth/register")
          end

        Accounts.UserNotifier.deliver_org_invitation(
          org,
          invitation,
          to
        )

        Remindly.Logs.log("orgs.create_invitation", %{
          user: socket.assigns.current_user,
          target_user_id: nil,
          org_id: org.id,
          metadata: %{
            email: invitation.email
          }
        })

        {:noreply,
         socket
         |> put_flash(:info, gettext("Invitation sent successfully"))
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
