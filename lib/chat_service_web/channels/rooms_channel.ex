defmodule ChatServiceWeb.RoomsChannel do
  use ChatServiceWeb, :channel

  alias ChatService.{Chat, Accounts, Chat.Message}
  alias ChatServiceWeb.Presence

  @impl true
  def join("rooms:lobby:" <> user_id, _payload, socket) do
    if authorized?(socket) do
      user = socket.assigns.guardian_default_resource

      send(self(), "after_join")

      {:ok,
       %{
         message: "Wellcome to lobby #{user.first_name} #{user.last_name}.",
         user: %{
           id: user.id,
           first_name: user.first_name,
           last_name: user.last_name,
           email: user.email,
           gender: user.gender,
           avatar_url: user.avatar_url
         }
       }, assign(socket, :user_id, user_id)}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def join("rooms:presence", _payload, socket) do
    if authorized?(socket) do
      user = socket.assigns.guardian_default_resource

      send(self(), "after_join_presence_channel")

      {:ok,
       %{
         message: "Wellcome to lobby #{user.first_name} #{user.last_name}.",
         user: %{
           id: user.id,
           first_name: user.first_name,
           last_name: user.last_name,
           email: user.email,
           gender: user.gender,
           avatar_url: user.avatar_url
         }
       }, assign(socket, :user_id, user.id)}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  @impl true
  def join("rooms:" <> room_id, _payload, socket) do
    if authorized?(socket) do
      requested_user = socket.assigns.guardian_default_resource

      try do
        chat_room = Chat.get_room!(room_id)

        list_messages = Message.list_messages_by_room_id(chat_room.id)

        all_messages =
          Enum.map(list_messages, fn x ->
            %{
              id: x.id,
              type: x.type,
              payload: Map.replace!(x.payload, "id", x.id),
              message_status: x.message_status,
              user: %{
                id: x.user.id,
                first_name: x.user.first_name,
                last_name: x.user.last_name,
                email: x.user.email,
                gender: x.user.gender,
                avatar_url: x.user.avatar_url
              },
              inserted_at: x.inserted_at,
              updated_at: x.updated_at
            }
          end)

        all_user_ids = chat_room.participant_ids ++ [chat_room.admin_id]

        all_users =
          Enum.map(all_user_ids, fn x ->
            user_data = Accounts.get_account!(x)

            %{
              id: user_data.id,
              first_name: user_data.first_name,
              last_name: user_data.last_name,
              email: user_data.email,
              gender: user_data.gender,
              avatar_url: user_data.avatar_url,
              is_admin: user_data.id == chat_room.admin_id,
              activity:
                if user_data.activity != nil do
                  %{
                    is_online: user_data.activity.is_online,
                    lastseen: user_data.activity.lastseen
                  }
                else
                  %{
                    is_online: false,
                    lastseen: nil
                  }
                end
            }
          end)

        send(self(), "after_join_a_room_channel")

        {:ok,
         %{
           message:
             "#{requested_user.first_name} #{requested_user.last_name} wellcome to chat room id : #{chat_room.id} .",
           room: %{
             id: chat_room.id,
             room_name: chat_room.room_name,
             room_image_url: chat_room.room_image_url,
             admin_id: chat_room.admin_id,
             participant_ids: chat_room.participant_ids,
             is_group: chat_room.is_group,
             messages: all_messages
           },
           users_data: all_users
         }, assign(socket, :user_id, requested_user.id)}
      rescue
        Ecto.NoResultsError -> {:error, %{reason: "Invalid chat room id."}, socket}
      end
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  @impl true
  def handle_info("after_join", socket) do
    user = socket.assigns.guardian_default_resource

    list_non_group_rooms = Chat.get_rooms_by_user_id(user.id, false)

    my_rooms =
      Enum.map(list_non_group_rooms, fn room ->
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
              length(Message.list_unread_messages(room.id, user.id))
            end,
          latest_message:
            if latest_message_entity != nil do
              latest_message = Message.get_message!(latest_message_entity.id)

              %{
                id: latest_message.id,
                type: latest_message.type,
                payload: Map.replace!(latest_message.payload, "id", latest_message.id),
                message_status: latest_message.message_status,
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
      end)

    broadcast!(socket, "my_rooms", %{
      rooms: my_rooms
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info("after_join_presence_channel", socket) do
    user = socket.assigns.guardian_default_resource

    if user.activity == nil do
      Accounts.create_activity(%{
        is_online: true,
        lastseen: NaiveDateTime.local_now(),
        account_id: user.id
      })
    else
      activity = Accounts.get_activity!(user.activity.id)

      Accounts.update_activity(activity, %{
        is_online: true,
        lastseen: NaiveDateTime.local_now()
      })
    end

    {:ok, _} =
      Presence.track(socket, user.id, %{
        online_at: inspect(System.system_time(:millisecond)),
        id: user.id,
        name: "#{user.first_name} #{user.last_name}",
        email: user.email,
        is_online: true,
        typing: false
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_info("after_join_a_room_channel", socket) do
    user = socket.assigns.guardian_default_resource

    {:ok, _} =
      Presence.track(socket, user.id, %{
        id: user.id,
        name: "#{user.first_name} #{user.last_name}",
        email: user.email,
        typing: false
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("update_presense", %{"is_online" => is_online}, socket) do
    user = socket.assigns.guardian_default_resource

    if user.activity == nil do
      Accounts.create_activity(%{
        is_online: is_online,
        lastseen: NaiveDateTime.local_now(),
        account_id: user.id
      })
    else
      activity = Accounts.get_activity!(user.activity.id)

      Accounts.update_activity(activity, %{
        is_online: is_online,
        lastseen: NaiveDateTime.local_now()
      })
    end

    {:ok, _} =
      Presence.update(socket, user.id, %{
        online_at: inspect(System.system_time(:millisecond)),
        id: user.id,
        name: "#{user.first_name} #{user.last_name}",
        email: user.email,
        is_online: is_online,
        typing: false
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("update_typing", %{"is_typing" => is_typing}, socket) do
    user = socket.assigns.guardian_default_resource

    {:ok, _} =
      Presence.update(socket, user.id, %{
        id: user.id,
        name: "#{user.first_name} #{user.last_name}",
        email: user.email,
        typing: is_typing
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in(
        "new_conversation",
        %{"perticipant_id" => perticipant_id},
        socket
      ) do
    user = socket.assigns.guardian_default_resource

    my_rooms = Chat.get_rooms_by_user_id(user.id, false)

    try do
      # if length(my_rooms) == 0 do
      chat_room =
        if length(my_rooms) == 0 do
          perticipant_account = Accounts.get_account!(perticipant_id)

          Chat.create_room(%{
            room_name: "#{user.first_name} #{user.last_name}",
            admin_id: user.id,
            participant_ids: [perticipant_account.id],
            is_group: false
          })
        else
          List.first(my_rooms)
        end

      {:reply,
       {:ok,
        %{
          message: "Room #{if length(my_rooms) == 0 do
            "created."
          else
            "already exist."
          end}",
          room_id: chat_room.id
        }}, socket}
    rescue
      Ecto.NoResultsError ->
        {:reply,
         {:error,
          %{
            message: "Invalid perticipant id."
          }}, socket}
    end
  end

  @impl true
  def handle_in(
        "new_message",
        %{"room_id" => room_id, "type" => type, "payload" => payload},
        socket
      ) do
    requested_user = socket.assigns.guardian_default_resource

    try do
      chat_room = Chat.get_room!(room_id)

      case Message.create_message(chat_room, %{
             type: type,
             payload: payload,
             room_id: chat_room.id,
             user_id: requested_user.id,
             room: chat_room,
             user: requested_user,
             message_status: "sending"
           }) do
        {:ok, message} ->
          broadcast!(socket, "new_message", %{
            id: message.id,
            type: message.type,
            payload: Map.replace!(message.payload, "id", message.id),
            message_status: message.message_status,
            user: %{
              id: message.user.id,
              first_name: message.user.first_name,
              last_name: message.user.last_name,
              email: message.user.email,
              gender: message.user.gender,
              avatar_url: message.user.avatar_url
            },
            inserted_at: message.inserted_at,
            updated_at: message.updated_at
          })

          {:noreply, socket}

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.inspect(changeset)

          {:noreply, socket}

        true ->
          {:noreply, socket}
      end
    rescue
      Ecto.NoResultsError ->
        {:reply,
         {:error,
          %{
            message: "Invalid chat room id."
          }}, socket}
    end
  end

  @impl true
  def handle_in(
        "ack_messsage_status",
        %{"message_id" => message_id, "payload" => payload},
        socket
      ) do
    requested_user = socket.assigns.guardian_default_resource

    if is_map(payload) do
      available_message_status = ["delivered", "error", "seen", "sending", "sent"]

      if Map.has_key?(payload, "status") do
        if payload["status"] in available_message_status do
          try do
            message = Message.get_message!(message_id)

            case Message.update_message(message, %{
                   payload: Map.replace!(payload, "id", message.id),
                   message_status:
                     if requested_user.id == message.user.id and
                          (payload["status"] == "delivered" or payload["status"] == "seen") do
                       message.message_status
                     else
                       payload["status"]
                     end
                 }) do
              {:ok, updated_message} ->
                if updated_message.message_status != "delivered" do
                  broadcast!(socket, "new_message", %{
                    id: updated_message.id,
                    type: updated_message.type,
                    payload: Map.replace!(updated_message.payload, "id", updated_message.id),
                    message_status: message.message_status,
                    user: %{
                      id: updated_message.user.id,
                      first_name: updated_message.user.first_name,
                      last_name: updated_message.user.last_name,
                      email: updated_message.user.email,
                      gender: updated_message.user.gender,
                      avatar_url: updated_message.user.avatar_url
                    },
                    inserted_at: updated_message.inserted_at,
                    updated_at: updated_message.updated_at
                  })
                end

                all_user_ids = Enum.concat(message.room.participant_ids, [message.room.admin_id])

                for userId <- all_user_ids do
                  broadcast_from!(socket, "new_message", %{
                    message: "New message recieved."
                  })

                  if(socket.topic == "rooms:lobby:#{userId}") do
                    ChatServiceWeb.Endpoint.broadcast_from!(
                      self(),
                      "rooms:#{message.room.id}",
                      "new_message",
                      %{
                        id: updated_message.id,
                        type: updated_message.type,
                        payload: Map.replace!(updated_message.payload, "id", updated_message.id),
                        message_status: updated_message.message_status,
                        user: %{
                          id: updated_message.user.id,
                          first_name: updated_message.user.first_name,
                          last_name: updated_message.user.last_name,
                          email: updated_message.user.email,
                          gender: updated_message.user.gender,
                          avatar_url: updated_message.user.avatar_url
                        },
                        inserted_at: updated_message.inserted_at,
                        updated_at: updated_message.updated_at
                      }
                    )
                  else
                    if userId != requested_user.id do
                      ChatServiceWeb.Endpoint.broadcast_from!(
                        self(),
                        "rooms:lobby:#{userId}",
                        "new_msg",
                        %{
                          id: updated_message.id,
                          type: updated_message.type,
                          payload:
                            Map.replace!(updated_message.payload, "id", updated_message.id),
                          message_status: updated_message.message_status,
                          user: %{
                            id: updated_message.user.id,
                            first_name: updated_message.user.first_name,
                            last_name: updated_message.user.last_name,
                            email: updated_message.user.email,
                            gender: updated_message.user.gender,
                            avatar_url: updated_message.user.avatar_url
                          },
                          inserted_at: updated_message.inserted_at,
                          updated_at: updated_message.updated_at
                        }
                      )
                    end
                  end
                end

                {:noreply, socket}

              {:error, %Ecto.Changeset{} = changeset} ->
                IO.inspect(changeset)

                {:noreply, socket}

              true ->
                {:noreply, socket}
            end

            {:noreply, socket}
          rescue
            Ecto.NoResultsError ->
              {:reply,
               {:error,
                %{
                  message: "Invalid message id."
                }}, socket}
          end
        else
          {:reply,
           {:error,
            %{
              reason: "Invalid status. Available message status are #{available_message_status}"
            }}, socket}
        end
      else
        {:reply, {:error, %{reason: "status required inside payload."}}, socket}
      end
    else
      {:reply, {:error, %{reason: "Invalid paylod."}}, socket}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  defp authorized?(socket) do
    if socket.assigns == nil do
      false
    else
      true
    end
  end
end
