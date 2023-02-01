defmodule ChatService.ChatTest do
  use ChatService.DataCase

  alias ChatService.Chat

  describe "rooms" do
    alias ChatService.Chat.Room

    import ChatService.ChatFixtures

    @invalid_attrs %{description: nil, name: nil, room_image_url: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Chat.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Chat.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{description: "some description", name: "some name", room_image_url: "some room_image_url"}

      assert {:ok, %Room{} = room} = Chat.create_room(valid_attrs)
      assert room.description == "some description"
      assert room.name == "some name"
      assert room.room_image_url == "some room_image_url"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name", room_image_url: "some updated room_image_url"}

      assert {:ok, %Room{} = room} = Chat.update_room(room, update_attrs)
      assert room.description == "some updated description"
      assert room.name == "some updated name"
      assert room.room_image_url == "some updated room_image_url"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_room(room, @invalid_attrs)
      assert room == Chat.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chat.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Chat.change_room(room)
    end
  end

  describe "rooms" do
    alias ChatService.Chat.Room

    import ChatService.ChatFixtures

    @invalid_attrs %{admin_id: nil, participant_ids: nil, room_image_url: nil, room_name: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Chat.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Chat.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{admin_id: "some admin_id", participant_ids: [], room_image_url: "some room_image_url", room_name: "some room_name"}

      assert {:ok, %Room{} = room} = Chat.create_room(valid_attrs)
      assert room.admin_id == "some admin_id"
      assert room.participant_ids == []
      assert room.room_image_url == "some room_image_url"
      assert room.room_name == "some room_name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{admin_id: "some updated admin_id", participant_ids: [], room_image_url: "some updated room_image_url", room_name: "some updated room_name"}

      assert {:ok, %Room{} = room} = Chat.update_room(room, update_attrs)
      assert room.admin_id == "some updated admin_id"
      assert room.participant_ids == []
      assert room.room_image_url == "some updated room_image_url"
      assert room.room_name == "some updated room_name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_room(room, @invalid_attrs)
      assert room == Chat.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chat.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Chat.change_room(room)
    end
  end
end
