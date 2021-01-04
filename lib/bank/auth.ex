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
    formatted_cpf = Brcpfcnpj.cpf_format(%Cpf{number: cpf})
    hashed_cpf = hash_cpf(formatted_cpf)
    api_user = Repo.get_by(ApiUser, cpf_hash: hashed_cpf)

    require IEx
    IEx.pry()

    ApiUser.decrypt_changeset(api_user)
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

  def hash_cpf(cpf) do
    key = Application.get_env(:bank, BankWeb.Endpoint)[:secret_key_base]
    :crypto.hmac(:sha256, key, cpf)
  end
end
