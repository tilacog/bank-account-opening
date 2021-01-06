defmodule BankWeb.AuthController do
  use BankWeb, :controller

  alias Bank.Auth
  alias Bank.Auth.ApiUser
  alias Bank.Auth.Token

  action_fallback BankWeb.FallbackController

  def create(conn, params) do
    with {:ok, %ApiUser{}} <- Auth.register_user(params) do
      token = params |> Map.get("cpf") |> Token.sign()

      conn
      |> put_status(:created)
      |> render("created.json", %{token: token, cpf: Map.get(params, "cpf")})
    end
  end

  def authenticate_api_user(conn, _opts) do
    if conn.assigns[:api_user] do
      conn
    else
      with token <-
             conn |> get_req_header("authorization") |> Enum.at(0),
           false <-
             is_nil(token),
           {:ok, cpf} <-
             Token.unsign(token),
           {:ok, api_user} <-
             Auth.get_user_by_cpf(cpf) do
        assign(conn, :api_user, api_user)
      else
        _error ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(:unauthorized, Jason.encode!(%{error: "Unauthorized"}))
          |> halt()
      end
    end
  end
end
