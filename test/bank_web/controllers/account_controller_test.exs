defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase

  alias Bank.Account
  alias Bank.Account.PartialAccount
  alias Bank.Repo

  @valid_partial_input %{
    name: "john doe"
  }

  test "anonymous requests are rejected", %{conn: conn} do
    conn = post(conn, Routes.account_path(conn, :create), @valid_partial_input)
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "authenticated requests are accepted", %{conn: conn} do
    api_user = api_user_fixture()

    conn
    |> assign(:api_user, api_user)
    |> post(Routes.account_path(conn, :create), @valid_partial_input)
    |> json_response(200)
  end

  # test "template", %{conn: conn} do end
end
