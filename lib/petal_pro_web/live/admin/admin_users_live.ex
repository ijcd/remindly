defmodule PetalProWeb.AdminUsersLive do
  @moduledoc """
  A live view to admin users on the platform (edit/suspend/delete).
  """
  use PetalProWeb, :live_view
  alias PetalPro.Accounts
  alias PetalPro.Accounts.User
  alias PetalPro.Accounts.UserQuery
  alias PetalProWeb.UserAuth
  alias PetalFramework.Components.DataTable
  import PetalProWeb.AdminLayoutComponent

  @data_table_opts [
    filterable: [:id, :name, :email, :is_suspended, :is_deleted, :inserted_at],
    sortable: [:id, :name, :email, :is_suspended, :is_deleted, :inserted_at],
    default_order: %{
      order_by: [:id, :inserted_at],
      order_directions: [:asc, :asc]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       index_params: nil,
       base_filters:
         build_base_filters(%{
           show_is_suspended: false,
           show_is_deleted: false
         })
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, params) do
    socket
    |> assign_users(params)
    |> assign(index_params: params, changeset: nil)
  end

  def apply_action(socket, :edit, %{"user_id" => user_id} = params) do
    user = Accounts.get_user!(user_id)

    socket
    |> assign_users(params)
    |> assign(index_params: params, changeset: nil)
    |> assign(%{
      page_title: "Editing #{PetalProWeb.Helpers.user_name(user)}",
      changeset: Accounts.change_user_as_admin(user)
    })
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.admin_layout current_page={:admin_users} current_user={@current_user}>
      <.page_header title="Users" />

      <.form
        :let={f}
        for={@base_filters}
        as={:base_filters}
        phx-change="toggle_base_filters"
        class="flex gap-5 mb-3"
      >
        <.form_field type="checkbox" form={f} field={:show_is_suspended} />
        <.form_field type="checkbox" form={f} field={:show_is_deleted} />
      </.form>

      <.data_table :if={@index_params} meta={@meta} items={@users}>
        <:col field={:id} sortable filterable={[:==]} class="w-28" />
        <:col field={:name} sortable filterable={[:=~]} />
        <:col field={:email} sortable filterable={[:=~]} />
        <:col
          :if={Phoenix.HTML.Form.input_value(@base_filters, :show_is_suspended)}
          field={:is_suspended}
          type={:boolean}
          sortable
          filterable={[:==]}
          renderer={:checkbox}
        />
        <:col
          :if={Phoenix.HTML.Form.input_value(@base_filters, :show_is_deleted)}
          field={:is_deleted}
          type={:boolean}
          sortable
          filterable={[:==]}
          renderer={:checkbox}
        />
        <:col :let={user} label="Actions">
          <.user_actions socket={@socket} user={user} />
        </:col>
      </.data_table>
    </.admin_layout>

    <%= if @changeset do %>
      <.modal title={@changeset.data.name}>
        <div class="text-sm">
          <.form :let={f} for={@changeset} phx-submit="update_user">
            <.form_field type="text_input" form={f} field={:name} />
            <.form_field type="email_input" form={f} field={:email} />
            <.form_field type="checkbox" form={f} field={:is_onboarded} />
            <.form_field type="checkbox" form={f} field={:is_admin} />

            <div class="flex justify-end">
              <.button size="sm">
                Update
              </.button>
            </div>
          </.form>
        </div>
      </.modal>
    <% end %>
    """
  end

  @impl true
  def handle_event(
        "toggle_base_filters",
        %{"base_filters" => base_filters},
        socket
      ) do
    socket =
      socket
      |> assign(base_filters: build_base_filters(base_filters))
      |> assign_users(socket.assigns[:index_params] || %{})

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_filters", %{"filters" => filter_params}, socket) do
    query_params = build_filter_params(socket.assigns.meta, filter_params)
    {:noreply, push_patch(socket, to: ~p"/admin/users?#{query_params}")}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, patch_back_to_index(socket)}
  end

  @impl true
  def handle_event("update_user", %{"user" => user_params}, socket) do
    case Accounts.update_user_as_admin(socket.assigns.changeset.data, user_params) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, "User updated")
          |> patch_back_to_index()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("suspend_user", params, socket) do
    user = Accounts.get_user!(params["id"])

    case Accounts.suspend_user(user) do
      {:ok, user} ->
        UserAuth.log_out_another_user(user)

        socket =
          socket
          |> put_flash(:info, "User suspended")
          |> patch_back_to_index()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("undo_suspend_user", params, socket) do
    user = Accounts.get_user!(params["id"])

    case Accounts.undo_suspend_user(user) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, "User no longer suspended")
          |> patch_back_to_index()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete_user", params, socket) do
    user = Accounts.get_user!(params["id"])

    case Accounts.delete_user(user) do
      {:ok, user} ->
        UserAuth.log_out_another_user(user)

        socket =
          socket
          |> put_flash(:info, "User deleted")
          |> patch_back_to_index()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("undo_delete_user", params, socket) do
    user = Accounts.get_user!(params["id"])

    case Accounts.undo_delete_user(user) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, "User no longer deleted")
          |> patch_back_to_index()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def build_base_filters(params \\ %{}) do
    types = %{
      show_is_suspended: :boolean,
      show_is_deleted: :boolean
    }

    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> to_form(as: :base_filters)
  end

  defp patch_back_to_index(socket) do
    push_patch(socket, to: ~p"/admin/users?#{socket.assigns[:index_params] || []}")
  end

  def user_actions(assigns) do
    ~H"""
    <div class="flex items-center" id={"user_actions_container_#{@user.id}"}>
      <.dropdown
        class="dark:shadow-lg"
        options_container_id={"user_options_#{@user.id}"}
        menu_items_wrapper_class="dark:border dark:border-gray-600"
      >
        <.dropdown_menu_item link_type="live_patch" label="Edit" to={~p"/admin/users/#{@user}"} />

        <.dropdown_menu_item
          link_type="live_redirect"
          label="View logs"
          to={~p"/admin/logs?#{[user_id: @user.id]}"}
        />

        <%= if @user.is_suspended do %>
          <.dropdown_menu_item
            label="Undo suspend"
            phx-click={
              JS.push("undo_suspend_user")
              |> JS.hide(to: "#user_options_#{@user.id}")
            }
            phx-value-id={@user.id}
            data-confirm={gettext("Are you sure?")}
          />
        <% else %>
          <.dropdown_menu_item
            label="Suspend"
            phx-click={
              JS.push("suspend_user")
              |> JS.hide(to: "#user_options_#{@user.id}")
            }
            phx-value-id={@user.id}
            data-confirm={
              "Are you sure? #{user_name(@user)} will be logged out and unable to sign in."
            }
          />
        <% end %>

        <%= if @user.is_deleted do %>
          <.dropdown_menu_item
            label="Undo delete"
            phx-click={
              JS.push("undo_delete_user")
              |> JS.hide(to: "#user_options_#{@user.id}")
            }
            phx-value-id={@user.id}
            data-confirm={gettext("Are you sure?")}
          />
        <% else %>
          <.dropdown_menu_item
            label="Delete"
            phx-click={
              JS.hide(to: "#user_options_#{@user.id}")
              |> JS.push("delete_user")
            }
            phx-value-id={@user.id}
            data-confirm={gettext("Are you sure?")}
          />
        <% end %>
      </.dropdown>
    </div>
    """
  end

  defp assign_users(socket, params) do
    query = User

    query =
      if Phoenix.HTML.Form.input_value(socket.assigns.base_filters, :show_is_deleted) do
        query
      else
        UserQuery.is_deleted(query, false)
      end

    query =
      if Phoenix.HTML.Form.input_value(socket.assigns.base_filters, :show_is_suspended) do
        query
      else
        UserQuery.is_suspended(query, false)
      end

    {users, meta} = DataTable.search(query, params, @data_table_opts)
    assign(socket, %{users: users, meta: meta})
  end
end
