defmodule Bank.Account do
  @moduledoc """
  The Account context.
  """
  alias Bank.Repo
  alias Bank.Account.PartialAccount
  alias Bank.Auth.ApiUser

  def get_partial_account!(id), do: Repo.get!(PartialAccount, id)

  def get_partial_account(id) do
    result = Repo.get(PartialAccount, id)
    require IEx
    IEx.pry()
    result
  end

  def create_partial_account(%ApiUser{} = api_user, attrs \\ %{}) do
    %PartialAccount{}
    |> PartialAccount.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:api_user, api_user)
    |> Repo.insert()

    # TODO: add operation to check if it is complete
  end

  def update_partial_account(%PartialAccount{} = partial_account, attrs) do
    partial_account
    |> PartialAccount.changeset(attrs)
    |> Repo.update()
  end
end
