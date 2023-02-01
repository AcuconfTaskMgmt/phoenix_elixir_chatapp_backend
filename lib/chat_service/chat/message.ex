defmodule ChatService.Chat.Message do
  @moduledoc """
  The Chat.Message context.
  """

  import Ecto.Query, warn: false
  alias ChatService.Repo

  alias ChatService.Chat.Message.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Returns the list of messages by roomId.

  ## Examples

      iex> list_messages_by_room_id!(123)
      [%Message{}, ...]

  """
  def list_messages_by_room_id(room_id) do
    Message
    |> where(
      [m],
      m.room_id == ^room_id
    )
    |> Repo.all()
    |> Repo.preload([:room, :user])
  end

  @doc """
  Returns the list of unread messages by roomId.

  ## Examples

      iex> list_unread_messages(123)
      [%Message{}, ...]

  """
  def list_unread_messages(room_id, requested_user_id) do
    Message
    |> where(
      [m],
      m.room_id == ^room_id and m.user_id != ^requested_user_id and
        (m.message_status != ^"seen" or
           m.message_status != ^"error") and
        (m.message_status == ^"sending" or
           m.message_status == ^"delivered" or m.message_status == ^"sent")
    )
    |> Repo.all()
    |> Repo.preload([:room, :user])
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id) |> Repo.preload([:room, :user])

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(room, attrs \\ %{}) do
    room
    |> Ecto.build_assoc(:messages, attrs)
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
    |> Repo.preload([:room, :user])
  end
end
