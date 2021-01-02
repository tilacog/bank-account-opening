defmodule Bank.Auth do
  @moduledoc """
  The Auth context.
  """
  alias(Bank.Repo)
  alias Bank.Auth.ApiUser

  def register_user(attrs \\ %{}) do
    %ApiUser{}
    |> ApiUser.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_cpf(cpf) do
    Repo.get_by(ApiUser, cpf: cpf)
  end

  def verify_password(user, given_password) do
    Pbkdf2.verify_pass(given_password, user.password_hash)
  end
end
