defmodule Remindly.Workers.ReminderWorker do
  @moduledoc """
  Run this with:
  Oban.insert(Remindly.Workers.ReminderWorker.new(%{}))
  """
  use Oban.Worker, queue: :default
  alias Remindly.{Repo, Reminders}
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{} = _job) do
    today = Timex.now() |> Timex.to_date()
    Logger.info("ReminderWorker: Sending reminders for #{today}")

    Reminders.list_overdue_reminders()
    |> Repo.preload(:user)
    |> Enum.each(fn reminder ->
      Logger.info("Reminding #{reminder.user.name} to #{reminder.label}")
      Remindly.Accounts.UserNotifier.deliver_reminder(reminder)
    end)

    :ok
  end
end
