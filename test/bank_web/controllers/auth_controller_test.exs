defmodule BankWeb.AuthControllerTest do
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

  test "accepts valid input", %{conn: conn} do
    conn = post(conn, Routes.auth_path(conn, :create), @valid_input)
    body = json_response(conn, 201)
    assert is_nil(Map.get(body, "errors"))

    # user exists
    {:ok, created_api_user} = Auth.get_user_by_cpf(@valid_cpf)
    assert created_api_user
    assert created_api_user.cpf == Brcpfcnpj.cpf_format(%Cpf{number: @valid_cpf})
  end

  test "require cpf and password ", %{conn: conn} do
    conn = post(conn, Routes.auth_path(conn, :create))
    body = json_response(conn, 422)
    assert "can't be blank" in body["errors"]["cpf"]
    assert "can't be blank" in body["errors"]["password"]
  end

  test "rejects invalid cpf ", %{conn: conn} do
    conn =
      post(conn, Routes.auth_path(conn, :create),
        cpf: @invalid_cpf,
        password: @valid_password
      )

    body = json_response(conn, 422)
    assert "invalid cpf" in body["errors"]["cpf"]
  end

  test "rejects invalid password ", %{conn: conn} do
    conn =
      post(conn, Routes.auth_path(conn, :create),
        cpf: @valid_cpf,
        password: @invalid_password
      )

    body = json_response(conn, 422)
    assert "should be at least 6 character(s)" in body["errors"]["password"]
  end

  test "rejects duplicate cpfs", %{conn: conn} do
    conn = post(conn, Routes.auth_path(conn, :create), @valid_input)
    json_response(conn, 201)
    assert Repo.aggregate(ApiUser, :count) == 1
    # again
    conn = post(conn, Routes.auth_path(conn, :create), @valid_input)
    body = json_response(conn, 422)
    assert "has already been taken" in body["errors"]["cpf_hash"]
    # still only one api user
    assert Repo.aggregate(ApiUser, :count) == 1
  end
end
