defmodule Bank.Repo.Migrations.CreateAuthUser do
  use Ecto.Migration

  def change do
    create table(:api_users) do
      add :cpf, :binary, null: false
      add :cpf_hash, :binary, null: false  # for lookups
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:api_users, [:cpf])

  end
end
