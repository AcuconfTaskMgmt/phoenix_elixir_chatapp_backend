defmodule ChatService.Accounts.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "activities" do
    field :is_online, :boolean, default: false
    field :lastseen, :naive_datetime

    belongs_to :account, ChatService.Accounts.Account, foreign_key: :account_id

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:account_id, :is_online, :lastseen])
    |> validate_required([:account_id, :is_online, :lastseen])
  end
end
