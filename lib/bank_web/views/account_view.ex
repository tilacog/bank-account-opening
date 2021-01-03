defmodule BankWeb.AccountView do
  use BankWeb, :view

    def render("show.json", _args) do
    %{todo: true}
  end

end
