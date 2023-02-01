defmodule ChatServiceWeb.RoomView do
  use ChatServiceWeb, :view

  alias ChatServiceWeb.RoomView
  alias ChatService.{Chat.Message}

  def render("index.json", %{rooms: rooms, requested_user_id: requested_user_id}) do
    %{data: render_many(rooms, RoomView, "room.json", requested_user_id: requested_user_id)}
  end

  def render("show.json", %{room: room, requested_user_id: requested_user_id}) do
    %{data: render_one(room, requested_user_id, RoomView, "room.json")}
  end

  def render("room.json", %{room: room, requested_user_id: requested_user_id}) do
    latest_message_entity = Enum.sort_by(room.messages, & &1.inserted_at) |> Enum.at(-1)

    %{
      id: room.id,
      room_name: room.room_name,
      room_image_url: room.room_image_url,
      admin_id: room.admin_id,
      participant_ids: room.participant_ids,
      is_group: room.is_group,
      total_unread_messages_count:
        if latest_message_entity == nil do
          0
        else
          length(Message.list_unread_messages(room.id, requested_user_id))
        end,
      latest_message:
        if latest_message_entity != nil do
          latest_message = Message.get_message!(latest_message_entity.id)

          %{
            id: latest_message.id,
            type: latest_message.type,
            payload: Map.replace!(latest_message.payload, "id", latest_message.id),
            user: %{
              id: latest_message.user.id,
              first_name: latest_message.user.first_name,
              last_name: latest_message.user.last_name,
              email: latest_message.user.email,
              gender: latest_message.user.gender,
              avatar_url: latest_message.user.avatar_url
            },
            inserted_at: latest_message.inserted_at,
            updated_at: latest_message.updated_at
          }
        else
          nil
        end,
      inserted_at: room.inserted_at,
      updated_at: room.updated_at
    }
  end
end
