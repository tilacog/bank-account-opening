defmodule BankWeb.AccountView do
  use BankWeb, :view

  def render("partial_account.json", %{partial_account: pacc}) do
    Map.merge(
      %{
        id: pacc.id,
        name: pacc.name,
        email: pacc.email,
        birth_date: pacc.birth_date,
        gender: pacc.gender,
        city: pacc.city,
        state: pacc.state,
        country: pacc.country,
        referral_code: pacc.referral_code
      },
      completion_status(pacc)
    )
  end

  def completion_status(partial_account) do
    if Map.get(partial_account, :completed) do
      %{status: "complete", self_referral_code: partial_account.self_referral_code}
    else
      %{status: "incomplete"}
    end
  end
end
