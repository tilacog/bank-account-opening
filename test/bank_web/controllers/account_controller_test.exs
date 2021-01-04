defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase

  alias Bank.Account
  alias Bank.Account.PartialAccount
  alias Bank.Repo

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
    referral_code: nil,
    state: nil
  }

  test "anonymous requests are rejected", %{conn: conn} do
    conn = post(conn, Routes.account_path(conn, :create), @valid_partial_input)
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "valid requests", %{conn: conn} do
    test_valid_request(conn, %{city: "abcd", state: "efgh", gender: "male", country: "ijkl"})
    test_valid_request(conn, %{birth_date: "2020-01-31", name: "oliver", gender: "other"})
    test_valid_request(conn, %{referral_code: "11223344", email: "lets@go.com", gender: "other"})
  end

  defp test_valid_request(conn, payload) do
    cpf = Brcpfcnpj.cpf_generate()
    api_user = api_user_fixture(cpf: cpf)
    response_body = build_response_body(conn, api_user, payload, :create, 201)
    expected = build_expected_result(payload, api_user)
    assert expected == response_body
  end

  defp build_response_body(conn, api_user, payload, method, status_code) do
    body =
      conn
      |> assign(:api_user, api_user)
      |> post(Routes.account_path(conn, method), payload)
      |> json_response(status_code)
      |> Map.delete("id")
  end

  defp build_expected_result(payload, api_user) do
    @blank_account
    |> Map.merge(payload)
    |> Map.merge(%{owner_cpf: api_user.cpf})
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Map.new()
  end
end
