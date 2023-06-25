defmodule Remindly.Reminders.Reminder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reminders" do
    field :due_date, :date
    field :is_done, :boolean, default: false
    field :label, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(reminder, attrs) do
    reminder
    |> cast(attrs, [:label, :due_date, :is_done])
    |> validate_required([:label, :due_date, :is_done])
  end
end
