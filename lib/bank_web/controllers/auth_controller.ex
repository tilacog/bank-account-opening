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

  defp authenticate(conn, _opts) do
    cond do
      %{"cpf" => cpf, "password" => given_password} = conn.body_params ->
        user = Auth.get_user_by_cpf(cpf)

        if user do
          if Auth.verify_password(user, given_password) do
            # user found, password ok
            conn
          else
            # user found, password not ok
            unauthorized(conn)
          end
        else
          # user was not found, simulate password hashing
          Pbkdf2.no_user_verify()
          unauthorized(conn)
        end

      true ->
        # user credentials were not provided
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> halt()
  end
end
