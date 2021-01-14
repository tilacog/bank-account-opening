defmodule BankWeb.ReferralControllerTest do
  use BankWeb.ConnCase
  alias Bank.Repo
  alias Bank.Account.PartialAccount
  alias Bank.Account
  alias Bank.Auth
  alias Bank.Auth.ApiUser

  test "anonymous index requests are rejected", %{conn: conn} do
    conn = get(conn, Routes.referral_path(conn, :index))
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "retrieves the referral tree scoped in current user", %{conn: conn} do
    %{child_b: account} = seed_database()
    api_user = Repo.get!(ApiUser, account.api_user_id)

    body =
      conn
      |> assign(:api_user, api_user)
      |> get(Routes.referral_path(conn, :index))
      |> json_response(200)

    expected_response = %{
      "name" => "genesis",
      "referrals" => [
        %{
          "name" => "child_b",
          "referrals" => [
            %{"name" => "grandchild_c", "referrals" => []},
            %{"name" => "grandchild_b", "referrals" => []}
          ]
        }
      ]
    }

    assert body == expected_response
  end

  test "incomplete partial accounts can't view the referral tree", %{conn: conn} do
    # create an incomplete partial account
    api_user = api_user_fixture()
    Account.create_partial_account(api_user)

    # actual test
    conn
    |> assign(:api_user, api_user)
    |> get(Routes.referral_path(conn, :index), %{name: "michael jordan"})
    |> json_response(200)
  end

  # Fixtures
  # ========
  defp create_user() do
    {:ok, user} = Auth.register_user(%{cpf: Brcpfcnpj.cpf_generate(), password: "1234secret"})
    user
  end

  defp create_account(name, parent) do
    user = create_user()

    {:ok, account} =
      Account.create_partial_account(user, %{
        name: name,
        email: name <> "@foo.foo",
        birth_date: "2000-01-01",
        gender: "other",
        city: name,
        state: "abcd",
        country: "abcd",
        referral_code: parent.self_referral_code
      })

    if !Map.get(account, :self_referral_code) do
      raise "Failed confidence check"
    end

    account
  end

  defp create_genesis_account() do
    {:ok, genesis_user} = Auth.register_user(%{cpf: "00000000191", password: "123supersecret456"})

    genesis_account =
      Repo.insert!(%PartialAccount{
        name: Bank.Vault.encrypt!("genesis"),
        self_referral_code: "12341234",
        api_user_id: genesis_user.id
      })

    %{genesis_user: genesis_user, genesis_account: genesis_account}
  end

  defp seed_database() do
    # Account Hierarchy
    # =================
    # genesis
    # ├─ child_a
    # │   └─ grandchild_a
    # └─ child_b
    #     ├─ grandchild_b
    #     └─ grandchild_c

    %{genesis_account: genesis_account} = create_genesis_account()
    child_a = create_account("child_a", genesis_account)
    grandchild_a = create_account("grandchild_a", child_a)
    child_b = create_account("child_b", genesis_account)
    grandchild_b = create_account("grandchild_b", child_b)
    grandchild_c = create_account("grandchild_c", child_b)

    %{
      child_a: child_a,
      child_b: child_b,
      grandchild_a: grandchild_a,
      grandchild_b: grandchild_b,
      grandchild_c: grandchild_c
    }
  end
end
