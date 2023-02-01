defmodule ChatServiceWeb.Auth.Guardian do
  use Guardian, otp_app: :chat_service

  alias ChatService.Accounts

  def subject_for_token(account, _claims) do
    {:ok, to_string(account.id)}
  end

  # def subject_for_token(_, _) do
  #   {:error, :no_user_provided}
  # end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_account!(id) do
      nil -> {:error, :account_not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :account_not_provided}
  end

  def authenticate(email, password) do
    case Accounts.get_account_by_email(email) do
      nil ->
        {:error, :unauthorized}

      account ->
        case validate_password(password, account.password) do
          true -> create_token(account)
          false -> {:error, :unauthorized}
        end
    end
  end

  defp validate_password(password, hash_password) do
    Bcrypt.verify_pass(password, hash_password)
  end

  defp create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account)
    {:ok, account, token}
  end
end
