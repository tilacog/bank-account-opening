defmodule Bank.Repo.Migrations.CreatePartialAccount do
  use Ecto.Migration

  def change do
    create table(:partial_accounts) do
      add :name, :string
      add :email, :string
      add :birth_date, :date
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :referral_code, :string

      add :api_user_id, references(:api_users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:partial_accounts, [:referral_code])
    create unique_index(:partial_accounts, [:email])
    create unique_index(:partial_accounts, [:api_user_id])

  end
end
