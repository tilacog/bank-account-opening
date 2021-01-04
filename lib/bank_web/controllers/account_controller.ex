defmodule BankWeb.AccountController do
  use BankWeb, :controller
  import BankWeb.AuthController, only: [authenticate_api_user: 2]
  alias Bank.Account
  alias Bank.Account.PartialAccount

  action_fallback BankWeb.FallbackController

  plug :authenticate_api_user

  def create(conn, params) do
    api_user = conn.assigns[:api_user]

    with {:ok, %PartialAccount{} = partial_account} <-
           Account.create_partial_account(api_user, params) do
      conn
      |> put_status(:created)
      |> render("partial_account.json", partial_account: partial_account)
    end
  end

  def update(conn, %{"id" => id, "updates" => update_params}) do
    partial_account = Account.get_partial_account!(id)

    with {:ok, %PartialAccount{} = partial_account} <-
           Account.update_partial_account(partial_account, update_params) do
      render(conn, "partial_account.json", partial_account: partial_account)
    end
  end
end
