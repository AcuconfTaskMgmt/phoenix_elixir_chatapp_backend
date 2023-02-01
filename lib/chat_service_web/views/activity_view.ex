defmodule ChatServiceWeb.ActivityView do
  use ChatServiceWeb, :view
  alias ChatServiceWeb.ActivityView

  def render("index.json", %{activities: activities}) do
    %{data: render_many(activities, ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: activity}) do
    %{data: render_one(activity, ActivityView, "activity.json")}
  end

  def render("activity.json", %{activity: activity}) do
    %{
      id: activity.id,
      is_online: activity.is_online,
      lastseen: activity.lastseen
    }
  end
end
