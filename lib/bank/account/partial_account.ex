defmodule Bank.Account.PartialAccount do
  alias Bank.Auth.ApiUser
  alias Bank.Account.BirthDateHelper

  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator

  @genders ~w(male female other)
  @all_fields ~w(name email birth_date gender city state country referral_code)a

  schema "partial_accounts" do
    field :name, :binary
    field :email, :binary
    field :email_hash, :binary
    field :birth_date, :binary
    field :gender, :string
    field :city, :string
    field :state, :string
    field :country, :string
    # TODO: set assoc on referral_code
    field :referral_code, :string
    field :self_referral_code, :string

    belongs_to :api_user, ApiUser

    timestamps()
  end

  def changeset(account, attrs \\ %{}) do
    account
    |> cast(attrs, @all_fields)
    |> validate_inclusion(:gender, @genders)
    |> validate_length(:referral_code, is: 8)
    |> validate_email(:email)
    |> validate_referral_code()
    |> validate_iso8601(:birth_date)
    |> validate_birth_date_range()
    |> hash_field(:email, :email_hash)
    |> encrypt_field(:email)
    |> encrypt_field(:birth_date)
    |> encrypt_field(:name)
    |> foreign_key_constraint(:referral_code)
    |> unique_constraint(:email_hash)
    |> unique_constraint(:api_user_id)
  end

  def is_finished?(changeset) do
    changeset
    |> validate_required(@all_fields)
    |> Map.get(:valid?)
  end

  defp validate_referral_code(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{referral_code: refcode}} ->
        if is_numeric(refcode) do
          changeset
        else
          add_error(changeset, :referral_code, "must be numeric")
        end

      _ ->
        changeset
    end
  end

  defp is_numeric(str) do
    case Integer.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def validate_iso8601(changeset, field) do
    validate_change(changeset, field, fn field, change ->
      case Date.from_iso8601(change) do
        {:ok, _} -> []
        _error -> [{field, "invalid date format"}]
      end
    end)
  end

  defp validate_birth_date_range(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{birth_date: birth_date}} ->
        if birth_date |> Date.from_iso8601!() |> BirthDateHelper.valid_range() do
          changeset
        else
          add_error(changeset, :birth_date, BirthDateHelper.error_message())
        end

      _ ->
        changeset
    end
  end

  def encrypt_field(changeset, field) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        value = Map.get(changes, field)

        if value != nil do
          encrypted = Bank.Vault.encrypt!(value)
          put_change(changeset, field, encrypted)
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  def hash_field(changeset, field, hashed_field) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        value = Map.get(changes, field)

        if value != nil do
          hashed = :crypto.hash(:sha256, value)
          put_change(changeset, hashed_field, hashed)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
