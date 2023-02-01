defmodule ChatServiceWeb.DefaultView do
  use ChatServiceWeb, :view

  alias ChatServiceWeb.DefaultView

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      gender: user.gender,
      avatar_url: user.avatar_url
    }
  end

  def render("all_messages.json", %{messages: messages}) do
    %{data: render_many(messages, DefaultView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{
      id: message.id
    }
  end

  def render("errors.json", %{errors: errors}),
    do: %{success: false, errors: errors}
end
