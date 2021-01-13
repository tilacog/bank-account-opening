defmodule BankWeb.ReferralView do
  use BankWeb, :view

  def render("referrals.json", %{referrals: tree}) do
    tree
  end
end
