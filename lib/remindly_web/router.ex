defmodule RemindlyWeb.Router do
  use RemindlyWeb, :router
  import RemindlyWeb.UserAuth
  import RemindlyWeb.OrgPlugs
  import Phoenix.LiveDashboard.Router
  alias RemindlyWeb.OnboardingPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RemindlyWeb.Layouts, :root}
    plug :protect_from_forgery

    plug(:put_secure_browser_headers, %{
      "content-security-policy" =>
        ContentSecurityPolicy.serialize(
          struct(ContentSecurityPolicy.Policy, Remindly.config(:content_security_policy))
        )
    })

    plug :fetch_current_user
    plug :kick_user_if_suspended_or_deleted
    plug PetalFramework.SetLocalePlug, gettext: RemindlyWeb.Gettext
  end

  pipeline :authenticated do
    plug :require_authenticated_user
    plug OnboardingPlug
    plug :assign_org_data
  end

  # Public routes
  scope "/", RemindlyWeb do
    pipe_through [:browser]

    # page_builder:static:public
    get "/about", PageController, :about
    get "/", PageController, :landing_page
    get "/privacy", PageController, :privacy
    get "/license", PageController, :license

    live_session :public do
      # page_builder:live:public
    end
  end

  # App routes - for signed in and confirmed users only
  scope "/app", RemindlyWeb do
    pipe_through [:browser, :authenticated]

    # page_builder:static:authenticated
    put "/users/settings/update-password", UserSettingsController, :update_password
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
    get "/users/totp", UserTOTPController, :new
    post "/users/totp", UserTOTPController, :create

    live_session :authenticated,
      on_mount: [
        {RemindlyWeb.UserOnMountHooks, :require_authenticated_user},
        {RemindlyWeb.OrgOnMountHooks, :assign_org_data}
      ] do
      # page_builder:live:authenticated
      live "/reminders", ReminderLive.Index, :index
      live "/reminders/new", ReminderLive.Index, :new
      live "/reminders/:id/edit", ReminderLive.Index, :edit

      live "/reminders/:id", ReminderLive.Show, :show
      live "/reminders/:id/show/edit", ReminderLive.Show, :edit
      live "/", DashboardLive
      live "/users/onboarding", UserOnboardingLive
      live "/users/edit-profile", EditProfileLive
      live "/users/edit-email", EditEmailLive
      live "/users/change-password", EditPasswordLive
      live "/users/edit-notifications", EditNotificationsLive
      live "/users/org-invitations", UserOrgInvitationsLive
      live "/users/two-factor-authentication", EditTotpLive

      live "/orgs", OrgsLive, :index
      live "/orgs/new", OrgsLive, :new

      scope "/org/:org_slug" do
        live "/", OrgDashboardLive
        live "/edit", EditOrgLive
        live "/team", OrgTeamLive, :index
        live "/team/invite", OrgTeamLive, :invite
        live "/team/memberships/:id/edit", OrgTeamLive, :edit_membership
      end
    end
  end

  use RemindlyWeb.AuthRoutes
  use RemindlyWeb.MailblusterRoutes
  use RemindlyWeb.AdminRoutes

  # DevRoutes must always be last
  use RemindlyWeb.DevRoutes
end
