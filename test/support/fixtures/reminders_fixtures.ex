defmodule Remindly.RemindersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Remindly.Reminders` context.
  """

  @doc """
  Generate a reminder.
  """
  def reminder_fixture(attrs \\ %{}) do
    {:ok, reminder} =
      attrs
      |> Enum.into(%{
        due_date: ~D[2023-06-24],
        is_done: true,
        label: "some label"
      })
      |> Remindly.Reminders.create_reminder()

    reminder
  end
end
