defmodule ChatService.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatService.Chat` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        admin_id: "some admin_id",
        participant_ids: [],
        room_image_url: "some room_image_url",
        room_name: "some room_name"
      })
      |> ChatService.Chat.create_room()

    room
  end
end
