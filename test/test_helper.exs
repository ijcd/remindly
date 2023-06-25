ExUnit.configure(exclude: [:petal_framework])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Remindly.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, RemindlyWeb.Endpoint.url())

"screenshots/*"
|> Path.wildcard()
|> Enum.each(&File.rm/1)
