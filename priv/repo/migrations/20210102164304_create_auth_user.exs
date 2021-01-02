defmodule Bank.Repo.Migrations.CreateAuthUser do
  use Ecto.Migration

  def change do
    create table(:api_users) do
      add :cpf, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:api_users, [:cpf])

  end
end
