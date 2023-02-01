defmodule ChatServiceWeb.AccountView do
  use ChatServiceWeb, :view
  alias ChatServiceWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account2.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account2.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      email: account.email,
      password: account.password
    }
  end

  def render("account2.json", %{account: account}) do
    %{
      id: account.id,
      first_name: account.first_name,
      last_name: account.last_name,
      email: account.email,
      gender: account.gender,
      avatar_url: account.avatar_url,
      activity:
        if account.activity != nil do
          %{
            is_online: account.activity.is_online,
            lastseen: account.activity.lastseen
          }
        else
          %{
            is_online: false,
            lastseen: nil
          }
        end
    }
  end

  def render("account_with_token.json", %{account: account, token: token}) do
    %{
      token: token,
      user: %{
        id: account.id,
        first_name: account.first_name,
        last_name: account.last_name,
        email: account.email,
        gender: account.gender,
        avatar_url: account.avatar_url
      }
    }
  end
end
