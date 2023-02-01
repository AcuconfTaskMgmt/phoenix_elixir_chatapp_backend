defmodule ChatService.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :password, :string
      add :gender, :string
      add :avatar_url, :string

      timestamps()
    end

    create unique_index(:accounts, [:email])
    create index(:accounts, [:email, :first_name, :last_name, :gender])
  end
end
