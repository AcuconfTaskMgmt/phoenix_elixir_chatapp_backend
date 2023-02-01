defmodule ChatService.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rooms" do
    field :admin_id, :string
    field :participant_ids, {:array, :string}
    field :room_image_url, :string
    field :room_name, :string
    field :is_group, :boolean

    has_many(:messages, ChatService.Chat.Message.Message)

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:room_name, :room_image_url, :admin_id, :participant_ids, :is_group])
    |> validate_required([:room_name, :admin_id, :participant_ids, :is_group])
    |> validate_length(:room_name, max: 30, min: 3)
  end
end
