defmodule BankWeb.AuthView do
  use BankWeb, :view

  def render("created.json", %{token: token, cpf: cpf}) do
    %{status: "success", token: token}
  end
end
