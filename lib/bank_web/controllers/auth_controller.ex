defmodule BankWeb.AuthController do
  use BankWeb, :controller

  alias Bank.Auth
  alias Bank.Auth.ApiUser

  def create(conn, params) do
    case Auth.register_user(params) do
      {:ok, %ApiUser{} = api_user} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{cpf: api_user.cpf, token: "xxxxxx"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{changeset: changeset})
    end
  end
end
