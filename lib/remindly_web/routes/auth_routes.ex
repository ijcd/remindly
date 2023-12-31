defmodule RemindlyWeb.AuthRoutes do
  defmacro __using__(_) do
    quote do
      scope "/auth", RemindlyWeb do
        pipe_through [:browser]

        delete "/sign-out", UserSessionController, :delete

        live_session :current_user,
          on_mount: [{RemindlyWeb.UserOnMountHooks, :maybe_assign_user}] do
          live "/confirm/:token", UserConfirmationLive, :edit
          live "/confirm", UserConfirmationInstructionsLive, :new
        end
      end

      scope "/auth", RemindlyWeb do
        pipe_through [:browser, :redirect_if_user_is_authenticated]

        live_session :redirect_if_user_is_authenticated,
          on_mount: [{RemindlyWeb.UserOnMountHooks, :redirect_if_user_is_authenticated}] do
          live "/register", UserRegistrationLive, :new
          live "/sign-in", UserSignInLive, :new
          live "/sign-in/passwordless", PasswordlessAuthLive, :sign_in

          live "/sign-in/passwordless/enter-pin/:hashed_user_id",
               PasswordlessAuthLive,
               :sign_in_code

          live "/reset-password", UserForgotPasswordLive, :new
          live "/reset-password/:token", UserResetPasswordLive, :edit
        end

        post "/sign-in", UserSessionController, :create
        post "/sign-in/passwordless", UserSessionController, :create_from_token

        get "/:provider", UserUeberauthController, :request
        get "/:provider/callback", UserUeberauthController, :callback
      end
    end
  end
end
