defmodule Remindly.Repo do
  use Ecto.Repo,
    otp_app: :remindly,
    adapter: Ecto.Adapters.Postgres

  use PetalFramework.Extensions.Ecto.RepoExt
end
