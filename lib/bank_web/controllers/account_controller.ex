defmodule BankWeb.AccountController do
  use BankWeb, :controller

  action_fallback BankWeb.FallbackController
  import BankWeb.AuthController, only: [authenticate_api_user: 2]

  plug :authenticate_api_user

  def create(conn, _params) do
    conn
    |> put_status(:ok)
    |> render("show.json", %{})
  end
end
