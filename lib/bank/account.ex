defmodule Bank.Account do
  @moduledoc """
  The Account context.
  """
  alias Bank.Repo
  alias Bank.Account.PartialAccount
  alias Bank.Auth.ApiUser

  def get_partial_account!(id), do: Repo.get!(PartialAccount, id)

  def get_partial_account(id) do
    case Repo.get(PartialAccount, id) do
      nil ->
        {:error, :not_found}

      partial_account ->
        {:ok, partial_account} |> decrypt
    end
  end

  def create_partial_account(%ApiUser{} = api_user, attrs \\ %{}) do
    %PartialAccount{}
    |> PartialAccount.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:api_user, api_user)
    |> Repo.insert()
    |> decrypt

    # TODO: add operation to check if it is complete
  end

  def update_partial_account(%PartialAccount{} = partial_account, attrs) do
    partial_account
    |> PartialAccount.changeset(attrs)
    |> Repo.update()
    |> decrypt

    # TODO: add operation to check if it is complete
  end

  def decrypt(opt) do
    case opt do
      {:ok, struct} ->
        decrypted_struct =
          [:name, :email, :birth_date]
          |> Enum.reduce(struct, fn field, acc ->
            encrypted_value = Map.get(acc, field)

            if encrypted_value do
              decrypted_value = Bank.Vault.decrypt!(encrypted_value)
              Map.put(acc, field, decrypted_value)
            else
              acc
            end
          end)

        {:ok, decrypted_struct}

      {:error, error} ->
        {:error, error}
    end
  end
end
