defmodule BankWeb.AccountController do
  use BankWeb, :controller

  action_fallback BankWeb.FallbackController

  def create(conn, _params) do
    conn
    |> put_status(:ok)
    |> render("show.json", %{})
  end
end
