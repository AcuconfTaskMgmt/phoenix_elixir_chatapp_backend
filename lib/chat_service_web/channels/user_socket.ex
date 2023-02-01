defmodule ChatServiceWeb.UserSocket do
  use Phoenix.Socket

  alias ChatServiceWeb.{Auth.ErrorResponse}

  channel "rooms:*", ChatServiceWeb.RoomsChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    IO.inspect(token)

    if token == nil do
      raise ErrorResponse.Unauthorized, message: "Authtorization token required."
    end

    case Guardian.Phoenix.Socket.authenticate(socket, ChatServiceWeb.Auth.Guardian, token) do
      {:error, _} ->
        raise ErrorResponse.Unauthorized, message: "Authtorization token required."

      {:ok, authed_socket} ->
        {:ok, authed_socket}
    end
  end

  @impl true
  def id(_socket), do: nil
end
