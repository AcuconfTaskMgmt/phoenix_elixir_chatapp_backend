defmodule ChatService.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatService.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: "some email",
        password: "some password"
      })
      |> ChatService.Accounts.create_account()

    account
  end

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        is_online: true,
        lastseen: ~N[2023-01-29 05:31:00]
      })
      |> ChatService.Accounts.create_activity()

    activity
  end
end
