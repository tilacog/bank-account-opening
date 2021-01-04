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
    # prepare CPF input
    formatted_cpf = Brcpfcnpj.cpf_format(%Cpf{number: cpf})
    hashed_cpf = ApiUser.hash_cpf(formatted_cpf)
    # query using hashed CPF
    api_user = Repo.get_by(ApiUser, cpf_hash: hashed_cpf)

    if api_user do
      # prepare output with decrypted CPF field
      decrypted_cpf = Bank.Vault.decrypt!(api_user.cpf)
      decripted_user = Map.put(api_user, :cpf, decrypted_cpf)
      {:ok, decripted_user}
    else
      {:error}
    end
  end

  def authenticate_by_cpf_and_password(given_cpf, given_password) do
    case get_user_by_cpf(given_cpf) do
      {:ok, api_user} ->
        case Pbkdf2.verify_pass(given_password, api_user.password_hash) do
          true -> {:ok, api_user}
          false -> {:error, :unauthorized}
        end

      {:error} ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
