defmodule ChatService.AccountTest do
  use ChatService.DataCase

  alias ChatService.Account

  describe "activities" do
    alias ChatService.Account.Activity

    import ChatService.AccountFixtures

    @invalid_attrs %{is_online: nil, lastseen: nil}

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Account.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Account.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      valid_attrs = %{is_online: true, lastseen: ~N[2023-01-29 05:26:00]}

      assert {:ok, %Activity{} = activity} = Account.create_activity(valid_attrs)
      assert activity.is_online == true
      assert activity.lastseen == ~N[2023-01-29 05:26:00]
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      update_attrs = %{is_online: false, lastseen: ~N[2023-01-30 05:26:00]}

      assert {:ok, %Activity{} = activity} = Account.update_activity(activity, update_attrs)
      assert activity.is_online == false
      assert activity.lastseen == ~N[2023-01-30 05:26:00]
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_activity(activity, @invalid_attrs)
      assert activity == Account.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Account.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Account.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Account.change_activity(activity)
    end
  end
end
