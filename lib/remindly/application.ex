defmodule Remindly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Remindly.Repo,
      # Start the Telemetry supervisor
      RemindlyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Remindly.PubSub},
      # Start the Endpoint (http/https)
      RemindlyWeb.Endpoint,
      {Task.Supervisor, name: Remindly.BackgroundTask},
      # HTTP adapter for Tesla
      {Finch, name: Remindly.Finch},
      {Oban, Application.fetch_env!(:remindly, Oban)}
      # Start a worker by calling: Remindly.Worker.start_link(arg)
      # {Remindly.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Remindly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RemindlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
