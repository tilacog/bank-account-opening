defmodule Bank.TestHelpers do
  alias Bank.Repo
  alias Bank.Auth
  alias Bank.Account.PartialAccount

  @genesis_cpf "00000011126"

  def genesis_referral_code(), do: "87654321"

  def genesis_fixture() do
    genesis_user =
      case Auth.get_user_by_cpf(@genesis_cpf) do
        # user exists, let's use it
        {:ok, user} ->
          user

        # user not found, so we build one
        {:error, _} ->
          {:ok, user} = Auth.register_user(%{cpf: @genesis_cpf, password: "1234secret"})
          user
      end

    Repo.insert!(
      %PartialAccount{
        name: "genesis",
        email: nil,
        birth_date: nil,
        gender: nil,
        city: nil,
        state: nil,
        country: nil,
        referral_code: nil,
        self_referral_code: genesis_referral_code(),
        api_user_id: genesis_user.id
      },
      on_conflict: :nothing
    )
  end

  def api_user_fixture(attrs \\ %{}) do
    genesis_fixture()

    {:ok, api_user} =
      attrs
      |> Enum.into(%{cpf: "00000000191", password: "01234567890"})
      |> Auth.register_user()

    api_user
  end
end
