defmodule ChatServiceWeb.Auth.Pipeline do
  alias ChatServiceWeb.Auth

  use Guardian.Plug.Pipeline,
    otp_app: :chat_service,
    module: Auth.Guardian,
    error_handler: Auth.ErrorResponse

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug Guardian.Plug.EnsureAuthenticated
end
