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
        encrypted_cpf = Bank.Vault.encrypt!(cpf)
        hashed_cpf = hash_cpf(cpf)

        changeset
        |> put_change(:cpf_hash, hashed_cpf)
        |> put_change(:cpf, encrypted_cpf)

      _ ->
        changeset
    end
  end

  def hash_cpf(cpf) do
    key = Application.get_env(:bank, BankWeb.Endpoint)[:secret_key_base]
    :crypto.hmac(:sha256, key, cpf)
  end
end
