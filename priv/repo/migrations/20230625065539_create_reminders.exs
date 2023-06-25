defmodule Remindly.Repo.Migrations.CreateReminders do
  use Ecto.Migration

  def change do
    create table(:reminders) do
      add :label, :string
      add :due_date, :date
      add :is_done, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:reminders, [:user_id])
  end
end
