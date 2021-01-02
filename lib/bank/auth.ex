defmodule Bank.Auth do
  @moduledoc """
  The Auth context.
  """
  alias(Bank.Repo)
  alias Bank.Auth.ApiUser

  def get_user_by_cpf(cpf) do
    Repo.get_by(ApiUser, cpf: cpf)
  end
end
