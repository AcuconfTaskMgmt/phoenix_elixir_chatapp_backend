defmodule ChatServiceWeb.Router do
  use ChatServiceWeb, :router

  use Plug.ErrorHandler

  alias ChatServiceWeb.{Auth}

  defp handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  defp handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  pipeline :api do
    plug CORSPlug
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Auth.Pipeline
  end

  scope "/", ChatServiceWeb do
    get "/", DefaultController, :index
  end

  scope "/api", ChatServiceWeb do
    pipe_through :api
    post "/auth/register", AccountController, :create
    post "/auth/signin", AccountController, :signin
  end

  scope "/api", ChatServiceWeb do
    pipe_through [:api, :auth]
    get "/", DefaultController, :index
  end

  scope "/api/users", ChatServiceWeb do
    pipe_through [:api, :auth]
    get "/", AccountController, :index
    get "/me", DefaultController, :get_my_account
  end

  scope "/api/rooms", ChatServiceWeb do
    pipe_through [:api, :auth]
    get "/", RoomController, :get_my_rooms
    get "/:room_id/messages", DefaultController, :list_messages_by_room_id
  end

  forward "/docs", PhoenixSwagger.Plug.SwaggerUI,
    otp_app: :chat_service,
    swagger_file: "swagger.json"

  def swagger_info do
    %{
      basePath: "/docs",
      schemes: ["http", "https", "ws", "wss"],
      info: %{
        version: "1.0",
        title: "ChatService API",
        description: "API Documentation for MyAPI v1",
        termsOfService: "Open for public",
        contact: %{
          name: "Gairick Saha",
          email: "gairicksaha@gmail.com"
        }
      }
    }
  end
end
