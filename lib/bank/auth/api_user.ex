defmodule Bank.Auth.ApiUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_users" do
    field :cpf, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:cpf, :password])
    |> validate_required([:cpf, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_cpf()
    |> format_cpf()
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> hash_password()
    |> unique_constraint(:cpf)
  end

  defp format_cpf(%Ecto.Changeset{valid?: true, changes: %{cpf: given_cpf}} = changeset) do
    put_change(changeset, :cpf, Brcpfcnpj.cpf_format(%Cpf{number: given_cpf}))
  end

  defp validate_cpf(%Ecto.Changeset{valid?: true, changes: %{cpf: given_cpf}} = changeset) do
    if Brcpfcnpj.cpf_valid?(%Cpf{number: given_cpf}) do
      changeset
    else
      add_error(changeset, :cpf, "invalid cp%Cpf{number: given_cpf}f")
    end
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
