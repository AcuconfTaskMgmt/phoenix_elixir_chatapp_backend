defmodule ChatService.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :room_name, :string
      add :room_image_url, :string
      add :admin_id, :string
      add :participant_ids, {:array, :string}

      timestamps()
    end
  end
end
