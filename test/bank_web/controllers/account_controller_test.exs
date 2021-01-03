defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase

  alias Bank.Account
  alias Bank.Account.PartialAccount
  alias Bank.Repo

  @owner %{
    cpf: "000.000.001-91"
  }

  @valid_partial_input %{
    name: "john doe"
  }

  @blank_account %{
    birth_date: nil,
    city: nil,
    country: nil,
    email: nil,
    gender: nil,
    name: nil,
    owner_cpf: nil,
    referral_code: nil,
    state: nil
  }

  test "anonymous requests are rejected", %{conn: conn} do
    conn = post(conn, Routes.account_path(conn, :create), @valid_partial_input)
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "authenticated requests are accepted", %{conn: conn} do
    api_user = api_user_fixture()

    body =
      conn
      |> assign(:api_user, api_user)
      |> post(Routes.account_path(conn, :create), @valid_partial_input)
      |> json_response(201)

    expected =
      @blank_account
      |> Map.merge(@valid_partial_input)
      |> Map.merge(%{owner_cpf: @owner[:cpf]})
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> Map.new()

    assert expected == Map.delete(body, "id")
  end
end
