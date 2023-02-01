defmodule ChatService.Chat.Message.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :payload, :map
    field :type, :string
    field :message_status, Ecto.Enum, values: [:delivered, :error, :seen, :sending, :sent]
    belongs_to :room, ChatService.Chat.Room, foreign_key: :room_id
    belongs_to :user, ChatService.Accounts.Account, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:type, :payload, :room_id, :user_id, :message_status])
    |> validate_required([:type, :payload, :room_id, :user_id, :message_status])
  end
end
