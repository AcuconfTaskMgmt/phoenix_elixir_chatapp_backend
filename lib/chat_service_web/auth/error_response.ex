defmodule ChatServiceWeb.Auth.ErrorResponse do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{message: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end

defmodule ChatServiceWeb.Auth.ErrorResponse.Unauthorized do
  defexception message: "Unauthorized", plug_status: 401
end
