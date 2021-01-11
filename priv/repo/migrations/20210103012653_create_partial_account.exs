defmodule Bank.Repo.Migrations.CreatePartialAccount do
  use Ecto.Migration

  def change do
    create table(:partial_accounts) do
      add :name, :binary
      add :email, :binary
      add :email_hash, :binary # for indexing
      add :birth_date, :binary
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :self_referral_code, :string
      add :api_user_id, references(:api_users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:partial_accounts, [:self_referral_code])
    create unique_index(:partial_accounts, [:email_hash])
    create unique_index(:partial_accounts, [:api_user_id])

    alter table(:partial_accounts) do
      add :referral_code, references(:partial_accounts, column: :self_referral_code, type: :string)
    end
    create unique_index(:partial_accounts, [:referral_code])


  end
end
