defmodule RemindlyWeb.LogsLive do
  @moduledoc """
  A component to display a list of logs. Logs are actions performed by users, and can help you discover how your application is used.
  """
  use RemindlyWeb, :live_view
  alias Remindly.Repo

  alias Remindly.Logs.Log
  alias Remindly.Logs.LogQuery

  alias RemindlyWeb.LogsLive.SearchChangeset
  alias RemindlyWeb.LogsLive.LogDataTableSettings
  import RemindlyWeb.AdminLayoutComponent

  @log_preloads [
    :user,
    :target_user
  ]

  @page_length 20

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      RemindlyWeb.Endpoint.subscribe("logs")
    end

    socket =
      assign(
        socket,
        %{
          page_title: "Logs",
          load_more: false,
          action: "",
          limit: @page_length,
          search_changeset: SearchChangeset.build(params)
        }
      )

    {:ok, set_logs(socket, params)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = assign(socket, :search_changeset, SearchChangeset.build(params))
    {:noreply, set_logs(socket, params)}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    params = build_filter_params(socket.assigns.meta, search_params)
    {:noreply, push_patch(socket, to: ~p"/admin/logs?#{params}")}
  end

  @impl true
  def handle_event("load-more", params, socket) do
    socket =
      socket
      |> update(:limit, fn limit -> limit + @page_length end)
      |> set_logs(params)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{
          topic: "logs",
          event: "new-log",
          payload: log
        },
        socket
      ) do
    if socket.assigns.search_changeset.changes[:enable_live_logs] do
      log = Repo.preload(log, @log_preloads)

      {:noreply, assign(socket, logs: [log | socket.assigns.logs])}
    else
      {:noreply, socket}
    end
  end

  def set_logs(socket, params) do
    case SearchChangeset.validate(socket.assigns.search_changeset) do
      {:ok, search_attrs} ->
        query =
          Log
          |> LogQuery.join_users()
          |> LogQuery.by_action(search_attrs[:action])
          |> LogQuery.limit(socket.assigns.limit)
          |> LogQuery.preload(@log_preloads)

        query =
          if search_attrs[:user_id] do
            LogQuery.by_user(query, search_attrs.user_id)
          else
            query
          end

        {logs, meta} =
          search(query, params,
            default_limit: socket.assigns.limit,
            for: LogDataTableSettings
          )

        assign(socket, %{
          logs: logs,
          meta: meta,
          load_more: length(logs) >= socket.assigns.limit
        })

      {:error, changeset} ->
        assign(socket, %{
          search_changeset: changeset,
          logs: []
        })
    end
  end

  defp maybe_add_emoji("register"), do: "🥳"
  defp maybe_add_emoji("sign_in"), do: "🙌"
  defp maybe_add_emoji("delete_user"), do: "💀"
  defp maybe_add_emoji("confirm_new_email"), do: "📧"
  defp maybe_add_emoji("orgs.create"), do: "🏢"
  defp maybe_add_emoji(_), do: ""
end
