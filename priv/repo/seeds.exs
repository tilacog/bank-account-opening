# Since accounts are chained together by referral codes, we must provide the first account (named
# "genesis") that will be the root for new accounts to refer to.

alias Bank.Repo
alias Bank.Auth
alias Bank.Account.PartialAccount

{:ok, genesis_user} = Auth.register_user(%{cpf: "00000000191", password: "123supersecret456"})

Repo.insert!(%PartialAccount{
  name: "genesis" |> Bank.Vault.encrypt!,
  email: "genesis@genesis.com" |> Bank.Vault.encrypt!,
  email_hash: :crypto.hash(:sha256, "genesis@genesis.com"),
  birth_date: "2000-01-01",
  gender: "other",
  city: "other",
  state: "other",
  country: "other",
  referral_code: nil,
  self_referral_code: "12341234",
  api_user_id: genesis_user.id
})
