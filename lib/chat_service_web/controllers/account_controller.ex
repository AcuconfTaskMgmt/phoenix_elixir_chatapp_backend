defmodule ChatServiceWeb.AccountController do
  use ChatServiceWeb, :controller

  alias ChatServiceWeb.{Auth.Guardian, Auth.ErrorResponse}
  alias ChatService.{Accounts, Accounts.Account}

  action_fallback ChatServiceWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    accounts = Accounts.list_accounts(user.id)
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, params) do
    with {:ok, %Account{} = account} <- Accounts.create_account(params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(account) do
      conn
      |> put_status(:created)
      |> render("account_with_token.json", %{account: account, token: token})
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    case Guardian.authenticate(email, password) do
      {:ok, account, token} ->
        conn
        |> put_status(:ok)
        |> render("account_with_token.json", %{account: account, token: token})

      {:error, :unauthorized} ->
        raise ErrorResponse.Unauthorized, message: "Email or Password incorrect."
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
