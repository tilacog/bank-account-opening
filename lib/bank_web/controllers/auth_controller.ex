defmodule BankWeb.AuthController do
  use BankWeb, :controller

  alias Bank.Auth
  alias Bank.Auth.ApiUser

  def create(conn, params) do
    case Auth.register_user(params) do
      {:ok, %ApiUser{}} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{changeset: changeset})
    end
  end

  def authenticate(conn, _opts) do
    with %{"cpf" => cpf, "password" => given_password} <- conn.body_params,
         {:ok, api_user} <- Auth.authenticate_by_cpf_and_password(cpf, given_password) do
      assign(conn, :api_user, api_user)
    else
      {:error, _reason} ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> halt()
  end
end
