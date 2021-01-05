defmodule Bank.Account.PartialAccount do
  alias Bank.Auth.ApiUser
  alias Bank.Account.BirthDateHelper

  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator

  @genders ~w(male female other)
  @fields_to_encrypt ~w(name email birth_date)a

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

    belongs_to :api_user, ApiUser

    timestamps()
  end

  def changeset(account, attrs \\ %{}) do
    account
    |> cast(attrs, [:name, :email, :birth_date, :gender, :city, :state, :country, :referral_code])
    |> validate_inclusion(:gender, @genders)
    |> validate_length(:referral_code, is: 8)
    |> validate_email(:email)
    |> validate_referral_code()
    |> validate_iso8601(:birth_date)
    |> validate_birth_date_range()
    |> unique_constraint(:referral_code)
    |> unique_constraint(:email_hash)
    |> unique_constraint(:api_user_id)
  end

  def is_finished?(changeset) do
    changeset
    |> Ecto.Changeset.apply_changes()
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    # keep only empty fields:
    |> Enum.filter(fn {_key, value} -> is_nil(value) end)
    # are there any empty fields?
    |> Enum.empty?()
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

  def encrypt_fields(changeset) do
    case changeset do
      %Ecto.Changeset{changes: changes} ->
        changes
        # build a map of encrypted keys, whenever needed
        |> Enum.reduce(%{}, fn {key, value}, acc ->
          if Enum.member?(@fields_to_encrypt, key) do
            Map.put(acc, key, Bank.Vault.encrypt!(value))
          else
            acc
          end
        end)
        # put those changes in the changeset
        |> Enum.reduce(changeset, fn {key, value}, acc ->
          put_change(acc, key, value)
        end)

      _ ->
        changeset
    end
  end
end
