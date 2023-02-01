defmodule ChatService.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :avatar_url, :string
    field :gender, :string

    has_one :activity, ChatService.Accounts.Activity

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Invalid email")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
