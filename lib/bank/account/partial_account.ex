defmodule Bank.Account.PartialAccount do
  alias Bank.Auth.ApiUser

  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.EmailValidator

  @genders ~w(male female other)

  schema "partial_accounts" do
    field :name, :string
    field :email, :string
    field :birth_date, :utc_datetime
    field :gender, :string
    field :city, :string
    field :state, :string
    field :country, :string
    # TODO: set assoc
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
    |> unique_constraint(:referral_code)
    |> unique_constraint(:email)
  end
end
