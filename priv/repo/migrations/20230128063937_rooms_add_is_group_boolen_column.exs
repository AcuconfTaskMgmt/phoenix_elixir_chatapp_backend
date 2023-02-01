defmodule ChatService.Repo.Migrations.RoomsAddIsGroupBoolenColumn do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add :is_group, :boolean, default: false
    end

    create index(:rooms, [:id, :room_name])
  end
end
