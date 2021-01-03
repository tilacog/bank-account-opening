defmodule BankWeb.AccountController do
  use BankWeb, :controller

  action_fallback BankWeb.FallbackController

  def create(con, _params) do
    con
    |> put_status(:ok)
    |> render("show.json", %{})
  end
end
