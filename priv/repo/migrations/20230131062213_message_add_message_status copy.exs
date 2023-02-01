defmodule ChatService.Repo.Migrations.MessageAddMessageStatus do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :message_status, :string, default: "sending"
    end
  end
end
