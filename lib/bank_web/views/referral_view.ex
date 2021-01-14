defmodule BankWeb.ReferralView do
  use BankWeb, :view

  def render("referrals.json", %{referrals: tree}) do
    tree
  end

    def render("incomplete.json", _params) do
    %{error: "please fill in the missing fields to view your referral tree."}
  end
end
