defmodule Bank.TestHelpers do
  alias Bank.Auth

  def api_user_fixture(attrs \\ %{}) do
    {:ok, api_user} =
      attrs
      |> Enum.into(%{cpf: "00000000191", password: "01234567890"})
      |> Auth.register_user()

    api_user
  end
end
