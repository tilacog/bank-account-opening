alias Bank.Repo
alias Bank.Auth.ApiUser
alias Bank.Auth



#IO.inspect(user, label: "user")


all = Repo.all(ApiUser)
IO.inspect(all, label: "all")
user = Auth.register_user(%{cpf: "09666295660", password: "ashtashtasht"})
IO.inspect(user, label: "user")
