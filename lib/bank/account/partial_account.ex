defmodule Bank.Account.PartialAccount do
  alias Bank.Auth.ApiUser
  alias Bank.Account.BirthDateHelper

  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator

  @genders ~w(male female other)

  schema "partial_accounts" do
    field :name, :string
    field :email, :string
    field :birth_date, :date
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
    |> validate_birth_date()
    |> unique_constraint(:referral_code)
    |> unique_constraint(:email)
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

  defp validate_birth_date(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{birth_date: birth_date}} ->
        age_in_valid_range? = Enum.member?(BirthDateHelper.valid_birth_date_range(), birth_date)

        if age_in_valid_range? do
          changeset
        else
          add_error(
            changeset,
            :birth_date,
            "age must be between #{BirthDateHelper.min_customer_age()} and #{
              BirthDateHelper.max_customer_age()
            } years old"
          )
        end

      _ ->
        changeset
    end
  end
end
