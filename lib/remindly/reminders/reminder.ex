defmodule Remindly.Reminders.Reminder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reminders" do
    field :due_date, :date
    field :is_done, :boolean, default: false
    field :label, :string

    belongs_to :user, Remindly.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(reminder, attrs) do
    reminder
    |> cast(attrs, [:label, :due_date, :is_done, :user_id])
    |> validate_required([:label, :due_date, :is_done, :user_id])
  end
end
