defmodule ChatService.Chat.MessageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatService.Chat.Message` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        payload: %{},
        type: "some type"
      })
      |> ChatService.Chat.Message.create_message()

    message
  end
end
