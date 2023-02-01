defmodule ChatService.Repo.Migrations.MessageAddMessageStatus do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :message_status, :string, default: "sent"
    end
  end
end
