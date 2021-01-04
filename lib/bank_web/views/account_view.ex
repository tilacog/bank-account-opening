defmodule BankWeb.AccountView do
  use BankWeb, :view

  def render("partial_account.json", %{partial_account: pacc}) do
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
    }
  end
end
