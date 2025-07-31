defmodule SmartSchoolLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SmartSchoolLiveWeb.Telemetry,
      SmartSchoolLive.Repo,
      {DNSCluster, query: Application.get_env(:smart_school_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SmartSchoolLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SmartSchoolLive.Finch},
      # Start a worker by calling: SmartSchoolLive.Worker.start_link(arg)
      # {SmartSchoolLive.Worker, arg},
      # Start to serve requests, typically the last entry
      SmartSchoolLiveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartSchoolLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SmartSchoolLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
