defmodule Bank.Account do
  @moduledoc """
  The Account context.
  """
  alias Bank.Repo
  alias Bank.Account.PartialAccount
  alias Bank.Auth.ApiUser

  def create_partial_account(%ApiUser{} = api_user, attrs \\ %{}) do
    %PartialAccount{}
    |> PartialAccount.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:api_user, api_user)
    |> Repo.insert()
    # TODO: add operation to check if it is complete
  end
end
