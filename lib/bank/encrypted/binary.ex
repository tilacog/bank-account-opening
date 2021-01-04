defmodule Bank.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Bank.Vault
end
