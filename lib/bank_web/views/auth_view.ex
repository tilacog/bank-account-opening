defmodule BankWeb.AuthView do
  use BankWeb, :view

  def render("show.json", _args) do
    %{status: "success"}
  end
end
