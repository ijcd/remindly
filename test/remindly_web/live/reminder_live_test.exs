defmodule RemindlyWeb.ReminderLiveTest do
  use RemindlyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Remindly.RemindersFixtures

  @create_attrs %{due_date: "2023-06-24", is_done: true, label: "some label"}
  @update_attrs %{due_date: "2023-06-25", is_done: false, label: "some updated label"}
  @invalid_attrs %{due_date: nil, is_done: false, label: nil}

  defp create_reminder(_) do
    reminder = reminder_fixture()
    %{reminder: reminder}
  end

  describe "Index" do
    setup [:create_reminder]

    test "lists all reminders", %{conn: conn, reminder: reminder} do
      {:ok, _index_live, html} = live(conn, ~p"/app/reminders")

      assert html =~ "Listing Reminders"
      assert html =~ reminder.label
    end

    test "saves new reminder", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/app/reminders")

      assert index_live |> element("a", "New Reminder") |> render_click() =~
               "New Reminder"

      assert_patch(index_live, ~p"/app/reminders/new")

      assert index_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reminder-form", reminder: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/reminders")

      assert html =~ "Reminder created successfully"
      assert html =~ "some label"
    end

    test "updates reminder in listing", %{conn: conn, reminder: reminder} do
      {:ok, index_live, _html} = live(conn, ~p"/app/reminders")

      assert index_live
             |> element("a[href='/reminders/#{reminder.id}/edit']", "Edit")
             |> render_click() =~
               "Edit Reminder"

      assert_patch(index_live, ~p"/app/reminders/#{reminder}/edit")

      assert index_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reminder-form", reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/reminders")

      assert html =~ "Reminder updated successfully"
      assert html =~ "some updated label"
    end

    test "deletes reminder in listing", %{conn: conn, reminder: reminder} do
      {:ok, index_live, _html} = live(conn, ~p"/app/reminders")

      assert index_live |> element("a[phx-value-id=#{reminder.id}]", "Delete") |> render_click()
      refute has_element?(index_live, "a[phx-value-id=#{reminder.id}]")
    end
  end

  describe "Show" do
    setup [:create_reminder]

    test "displays reminder", %{conn: conn, reminder: reminder} do
      {:ok, _show_live, html} = live(conn, ~p"/app/reminders/#{reminder}")

      assert html =~ "Show Reminder"
      assert html =~ reminder.label
    end

    test "updates reminder within modal", %{conn: conn, reminder: reminder} do
      {:ok, show_live, _html} = live(conn, ~p"/app/reminders/#{reminder}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Reminder"

      assert_patch(show_live, ~p"/app/reminders/#{reminder}/show/edit")

      assert show_live
             |> form("#reminder-form", reminder: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#reminder-form", reminder: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/app/reminders/#{reminder}")

      assert html =~ "Reminder updated successfully"
      assert html =~ "some updated label"
    end
  end
end
