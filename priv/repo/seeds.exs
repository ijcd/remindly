# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Remindly.Repo.insert!(%Remindly.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Remindly.Accounts.{User, UserToken, UserTOTP, UserSeeder}
alias Remindly.Logs.Log
alias Remindly.Orgs.OrgSeeder
alias Remindly.Orgs.{Org, Membership, Invitation}

if Mix.env() == :dev do
  Remindly.Repo.delete_all(Log)
  Remindly.Repo.delete_all(UserTOTP)
  Remindly.Repo.delete_all(Invitation)
  Remindly.Repo.delete_all(Membership)
  Remindly.Repo.delete_all(Org)
  Remindly.Repo.delete_all(UserToken)
  Remindly.Repo.delete_all(User)

  admin = UserSeeder.admin()

  normal_user =
    UserSeeder.normal_user(%{
      email: "user@example.com",
      name: "Sarah Cunningham",
      password: "password",
      confirmed_at: Timex.now() |> Timex.to_naive_datetime()
    })

  org = OrgSeeder.random_org(admin)
  Remindly.Orgs.create_invitation(org, %{email: normal_user.email})

  UserSeeder.random_users(20)
end
