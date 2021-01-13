defmodule BankWeb.ReferralControllerTest do
  use BankWeb.ConnCase
  alias Bank.Repo
  alias Bank.Account.PartialAccount
  alias Bank.Account
  alias Bank.Auth

  test "anonymous index requests are rejected", %{conn: conn} do
    conn = get(conn, Routes.referral_path(conn, :index))
    body = json_response(conn, 401)
    assert %{"error" => "Unauthorized"} = body
  end

  test "retrieves the referral tree", %{conn: conn} do
    seed_database()
    genesis_user = get_genesis_user()
    conn = assign(conn, :api_user, genesis_user)

    conn = get(conn, Routes.referral_path(conn, :index))
    body = json_response(conn, 200)

    assert false, "finish this test"
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
        email: "foo-#{:rand.uniform(9999)}@foo.foo",
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

  defp get_genesis_account(), do: Repo.get_by!(PartialAccount, name: "genesis")

  defp get_genesis_user() do
    {:ok, genesis_user} = Auth.get_user_by_cpf("00000000191")
    genesis_user
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

    %{genesis_user: genesis_user, genesis_account: genesis_account} = create_genesis_account()
    child_a = create_account("child_a", genesis_account)
    _grandchild_a = create_account("grandchild_a", child_a)
    child_b = create_account("child_b", genesis_account)
    _grandchild_b = create_account("grandchild_b", child_b)
    _grandchild_c = create_account("grandchild_c", child_b)
  end
end
