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

  # test "template", %{conn: conn} do end
end
