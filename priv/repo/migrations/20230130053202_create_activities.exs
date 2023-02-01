defmodule ChatService.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_online, :boolean, default: false, null: false
      add :lastseen, :naive_datetime
      add :account_id, references(:accounts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:activities, [:account_id, :is_online, :lastseen])
    create unique_index(:activities, [:account_id])
  end
end
