defmodule ChatServiceWeb.RoomControllerTest do
  use ChatServiceWeb.ConnCase

  import ChatService.ChatFixtures

  alias ChatService.Chat.Room

  @create_attrs %{
    admin_id: "some admin_id",
    participant_ids: [],
    room_image_url: "some room_image_url",
    room_name: "some room_name"
  }
  @update_attrs %{
    admin_id: "some updated admin_id",
    participant_ids: [],
    room_image_url: "some updated room_image_url",
    room_name: "some updated room_name"
  }
  @invalid_attrs %{admin_id: nil, participant_ids: nil, room_image_url: nil, room_name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all rooms", %{conn: conn} do
      conn = get(conn, Routes.room_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create room" do
    test "renders room when data is valid", %{conn: conn} do
      conn = post(conn, Routes.room_path(conn, :create), room: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.room_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "admin_id" => "some admin_id",
               "participant_ids" => [],
               "room_image_url" => "some room_image_url",
               "room_name" => "some room_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.room_path(conn, :create), room: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update room" do
    setup [:create_room]

    test "renders room when data is valid", %{conn: conn, room: %Room{id: id} = room} do
      conn = put(conn, Routes.room_path(conn, :update, room), room: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.room_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "admin_id" => "some updated admin_id",
               "participant_ids" => [],
               "room_image_url" => "some updated room_image_url",
               "room_name" => "some updated room_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, room: room} do
      conn = put(conn, Routes.room_path(conn, :update, room), room: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete room" do
    setup [:create_room]

    test "deletes chosen room", %{conn: conn, room: room} do
      conn = delete(conn, Routes.room_path(conn, :delete, room))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.room_path(conn, :show, room))
      end
    end
  end

  defp create_room(_) do
    room = room_fixture()
    %{room: room}
  end
end
