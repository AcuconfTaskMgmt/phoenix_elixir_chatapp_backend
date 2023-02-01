defmodule ChatServiceWeb.RoomController do
  use ChatServiceWeb, :controller

  alias ChatService.{Chat, Chat.Room}

  action_fallback ChatServiceWeb.FallbackController

  def index(conn, _params) do
    user = conn.private.guardian_default_resource
    rooms = Chat.list_rooms()
    render(conn, "index.json", rooms: rooms, requested_user_id: user.id)
  end

  def create(conn, %{"room" => room_params}) do
    with {:ok, %Room{} = room} <- Chat.create_room(room_params) do
      user = conn.private.guardian_default_resource

      conn
      |> put_status(:created)
      |> render("show.json", room: room, requested_user_id: user.id)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.private.guardian_default_resource
    room = Chat.get_room!(id)
    render(conn, "show.json", room: room, requested_user_id: user.id)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    user = conn.private.guardian_default_resource
    room = Chat.get_room!(id)

    with {:ok, %Room{} = room} <- Chat.update_room(room, room_params) do
      render(conn, "show.json", room: room, requested_user_id: user.id)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Chat.get_room!(id)

    with {:ok, %Room{}} <- Chat.delete_room(room) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_my_rooms(conn, _) do
    user = conn.private.guardian_default_resource
    my_rooms = Chat.get_rooms_by_user_id(user.id, false)
    render(conn, "index.json", rooms: my_rooms, requested_user_id: user.id)
  end
end
