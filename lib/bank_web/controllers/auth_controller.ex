defmodule BankWeb.AuthController do
  use BankWeb, :controller

  alias Bank.Auth
  alias Bank.Auth.ApiUser

  action_fallback BankWeb.FallbackController

  def create(conn, params) do
    with {:ok, %ApiUser{}} <- Auth.register_user(params) do
      conn
      |> put_status(:created)
      |> render("show.json", %{})
    end
  end

  def authenticate(conn, _opts) do
    with %{"cpf" => cpf, "password" => given_password} <- conn.body_params,
         {:ok, api_user} <- Auth.authenticate_by_cpf_and_password(cpf, given_password) do
      assign(conn, :api_user, api_user)
    else
      _ -> unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> halt()
  end
end
