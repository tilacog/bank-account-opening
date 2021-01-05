defmodule BankWeb.AuthTokenTest do
  use BankWeb.ConnCase

  alias Bank.Auth
  alias Bank.Auth.Token
  alias Bank.Auth.ApiUser
  alias Bank.Repo

  @valid_cpf "00000000191"
  @valid_password "1234567890"
  @invalid_cpf "00000000000"
  @invalid_password "12345"
  @valid_input [cpf: @valid_cpf, password: @valid_password]

  test "returns valid token on success", %{conn: conn} do
    body =
      conn
      |> post(Routes.auth_path(conn, :create), @valid_input)
      |> json_response(201)

    %{"status" => "success", "token" => token} = body
    assert {:ok, @valid_cpf} = Token.unsign(token)
  end

  test "can login with valid token", %{conn: conn} do
    body =
      conn
      |> post(Routes.auth_path(conn, :create), @valid_input)
      |> json_response(201)


    %{"token" => token} = body
    conn
    |> put_req_header("authorization", token)
    |> put_resp_content_type("application/json")
    |> post(Routes.account_path(conn, :create), %{})
    |> json_response(201)
  end

  test "can't login with invalid token", %{conn: conn} do
    conn
    |> put_req_header("authorization", "invalid")
    |> put_resp_content_type("application/json")
    |> post(Routes.account_path(conn, :create), %{})
    |> json_response(401)
  end

end
