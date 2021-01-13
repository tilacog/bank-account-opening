defmodule BankWeb.ReferralController do
  use BankWeb, :controller
  import BankWeb.AuthController, only: [authenticate_api_user: 2]
  alias Bank.Account
  alias Bank.Account.PartialAccount

  action_fallback BankWeb.FallbackController

  plug :authenticate_api_user

  def index(conn, _params) do
    api_user = conn.assigns[:api_user]

    with {:ok, %PartialAccount{} = partial_account} <-
           Account.get_partial_account_for_user(api_user) do
      referrals = Bank.Account.ReferralHelper.build_referral_tree(partial_account)
      render(conn, "referrals.json", referrals: referrals)
    end
  end
end
