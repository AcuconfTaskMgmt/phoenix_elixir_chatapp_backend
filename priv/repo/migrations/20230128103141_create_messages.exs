defmodule ChatService.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :payload, :map
      add :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id, null: false)
      add :user_id, references(:accounts, on_delete: :delete_all, type: :binary_id, null: false)

      timestamps()
    end

    create index(:messages, [:user_id, :room_id, :type])
  end
end
