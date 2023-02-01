defmodule ChatService.AccountsTest do
  use ChatService.DataCase

  alias ChatService.Accounts

  describe "accounts" do
    alias ChatService.Accounts.Account

    import ChatService.AccountsFixtures

    @invalid_attrs %{email: nil, password: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{email: "some email", password: "some password"}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.email == "some email"
      assert account.password == "some password"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{email: "some updated email", password: "some updated password"}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.email == "some updated email"
      assert account.password == "some updated password"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "activities" do
    alias ChatService.Accounts.Activity

    import ChatService.AccountsFixtures

    @invalid_attrs %{is_online: nil, lastseen: nil}

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Accounts.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Accounts.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      valid_attrs = %{is_online: true, lastseen: ~N[2023-01-29 05:31:00]}

      assert {:ok, %Activity{} = activity} = Accounts.create_activity(valid_attrs)
      assert activity.is_online == true
      assert activity.lastseen == ~N[2023-01-29 05:31:00]
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      update_attrs = %{is_online: false, lastseen: ~N[2023-01-30 05:31:00]}

      assert {:ok, %Activity{} = activity} = Accounts.update_activity(activity, update_attrs)
      assert activity.is_online == false
      assert activity.lastseen == ~N[2023-01-30 05:31:00]
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_activity(activity, @invalid_attrs)
      assert activity == Accounts.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Accounts.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Accounts.change_activity(activity)
    end
  end
end
