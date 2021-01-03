defmodule Bank.Auth do
  @moduledoc """
  The Auth context.
  """
  alias Bank.Repo
  alias Bank.Auth.ApiUser

  def register_user(attrs \\ %{}) do
    %ApiUser{}
    |> ApiUser.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_cpf(cpf) do
    Repo.get_by(ApiUser, cpf: cpf)
  end

  def authenticate_by_cpf_and_password(given_cpf, given_password) do
    api_user = get_user_by_cpf(given_cpf)

    cond do
      api_user && Pbkdf2.verify_pass(given_password, api_user.password_hash) ->
        {:ok, api_user}

      api_user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
