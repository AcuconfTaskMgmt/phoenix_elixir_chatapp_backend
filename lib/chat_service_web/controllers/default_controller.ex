defmodule ChatServiceWeb.DefaultController do
  use ChatServiceWeb, :controller

  alias ChatService.{Chat, Chat.Message}

  action_fallback ChatServiceWeb.FallbackController

  def index(conn, _params) do
    text(conn, "Chat Service API Working on enviroment - #{Mix.env()}")
  end

  def get_my_account(conn, _params) do
    conn
    |> put_resp_content_type("application/json")

    if Guardian.Plug.authenticated?(conn) do
      user = Guardian.Plug.current_resource(conn)
      render(conn, "user.json", %{user: user})
    else
      text(conn, "Authenticated user not found")
    end
  end

  def list_messages_by_room_id(conn, %{"room_id" => room_id}) do
    room = Chat.get_room!(room_id)

    if room == nil do
      render(conn, "errors.json", %{errors: ["Invalid room_id"]})
    else
      messages = Message.list_messages_by_room_id(room.id)

      data =
        Enum.map(messages, fn x ->
          x
        end)

      IO.inspect(data)

      render(conn, "all_messages.json", %{
        messages: messages
      })
    end
  end
end
