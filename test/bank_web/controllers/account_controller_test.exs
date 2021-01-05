defmodule BankWeb.AccountControllerTest do
  use BankWeb.ConnCase
  alias Bank.Repo
  alias Bank.Account.PartialAccount

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

  test "anonymous create requests are rejected", %{conn: conn} do
    conn = post(conn, Routes.account_path(conn, :create), @valid_partial_input)
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "valid create requests are accpeted", %{conn: conn} do
    test_valid_request(conn, %{city: "abcd", state: "efgh", gender: "male", country: "ijkl"})
    test_valid_request(conn, %{birth_date: "2000-01-31", name: "oliver", gender: "other"})
    test_valid_request(conn, %{referral_code: "11223344", email: "lets@go.com", gender: "other"})
  end

  test "valid partial update requests are accepted", %{conn: conn} do
    api_user = api_user_fixture()
    conn = assign(conn, :api_user, api_user)

    first_payload = %{name: "michael jordan", gender: "male"}

    second_payload = %{
      updates: %{
        city: "new york",
        state: "new york",
        country: "usa",
        birth_date: "1963-02-17"
      }
    }

    third_payload = %{
      updates: %{
        referral_code: "12341234",
        email: "mj@nba.com"
      }
    }

    first_response =
      conn
      |> post(Routes.account_path(conn, :create), first_payload)
      |> json_response(201)

    second_response =
      conn
      |> patch(Routes.account_path(conn, :update, first_response["id"], second_payload))
      |> json_response(200)

    assert second_response == Map.merge(first_response, second_response)

    third_response =
      conn
      |> patch(Routes.account_path(conn, :update, second_response["id"], third_payload))
      |> json_response(200)

    assert third_response ==
             first_response |> Map.merge(second_response) |> Map.merge(third_response)
  end

  test "only one partial_account per api_user", %{conn: conn} do
    api_user = api_user_fixture()
    conn = assign(conn, :api_user, api_user)
    assert Repo.aggregate(PartialAccount, :count) == 0
    dispatch_request(conn, api_user, %{}, :create, 201)
    assert Repo.aggregate(PartialAccount, :count) == 1
    dispatch_request(conn, api_user, %{}, :create, 422)
    assert Repo.aggregate(PartialAccount, :count) == 1
  end

  # Helper function to quickly setup and assert a test case for the :create action
  defp test_valid_request(conn, payload) do
    cpf = Brcpfcnpj.cpf_generate()
    api_user = api_user_fixture(cpf: cpf)
    response_body = dispatch_request(conn, api_user, payload, :create, 201)
    expected = build_expected_result(payload)
    assert expected == response_body
  end

  # Helper function to quickly dispatch a request to the server
  defp dispatch_request(conn, api_user, payload, method, status_code) do
    conn
    |> assign(:api_user, api_user)
    |> post(Routes.account_path(conn, method), payload)
    |> json_response(status_code)
    |> Map.delete("id")
  end

  # Helper function to transform a map with atom keys to map with string keys
  defp build_expected_result(payload) do
    @blank_account
    |> Map.merge(payload)
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Map.new()
  end
end
