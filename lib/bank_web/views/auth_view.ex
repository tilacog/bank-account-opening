defmodule BankWeb.AuthView do
  use BankWeb, :view

  def render("show.json", %{cpf: cpf, token: token}) do
    %{
      status: "success",
      cpf: cpf,
      token: token
    }
  end

  def render("error.json", %{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(
        changeset,
        &BankWeb.ErrorHelpers.translate_error/1
      )

    %{errors: errors}
  end
end
