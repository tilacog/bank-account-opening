defmodule Bank.Auth.ApiUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_users" do
    field :cpf, :binary
    field :cpf_hash, :binary
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
    |> encrypt_cpf()
    |> unique_constraint(:cpf_hash)
  end

  def decrypt_changeset(user) do
    user
    |> decrypt_cpf()
  end

  defp format_cpf(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{cpf: given_cpf}} ->
        put_change(changeset, :cpf, Brcpfcnpj.cpf_format(%Cpf{number: given_cpf}))

      _ ->
        changeset
    end
  end

  defp validate_cpf(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{cpf: given_cpf}} ->
        if Brcpfcnpj.cpf_valid?(%Cpf{number: given_cpf}) do
          changeset
        else
          add_error(changeset, :cpf, "invalid cpf")
        end

      _ ->
        changeset
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

  defp encrypt_cpf(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{cpf: cpf}} ->
        put_change(changeset, :cpf, Bank.Vault.encrypt!(cpf))
        cpf_hash = Bank.Auth.hash_cpf(cpf)
        put_change(changeset, :cpf_hash, cpf_hash)

      _ ->
        changeset
    end
  end

  defp decrypt_cpf(changeset) do
    encrypted_cpf = get_field(changeset, :cpf)
    decrypted_cpf = Bank.Vault.decrypt!(encrypted_cpf)
    put_change(changeset, :cpf, decrypted_cpf)
  end
end
