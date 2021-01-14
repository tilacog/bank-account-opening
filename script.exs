alias Bank.Auth
alias Bank.Account
alias Bank.Account.PartialAccount
alias Bank.Repo

# Account Hierarchy
# =================
# genesis
# ├─ child_a
# │   └─ grandchild_a
# └─ child_b
#     ├─ grandchild_b
#     └─ grandchild_c

defmodule Poc do
  def create_user() do
    {:ok, user} = Auth.register_user(%{cpf: Brcpfcnpj.cpf_generate(), password: "1234secret"})
    user
  end

  def create_account(name, parent) do
    user = create_user()

    {:ok, account} =
      Account.create_partial_account(user, %{
        name: name,
        email: name <> "@poc.com",
        birth_date: "2000-01-01",
        gender: "other",
        city: "atlantis",
        state: name,
        country: "world",
        referral_code: parent.self_referral_code
      })

    if !Map.get(account, :self_referral_code) do
      raise "Failed confidence check"
    end

    account
  end

  def get_genesis() do
    email_hash = :crypto.hash(:sha256, "genesis@genesis.com")
    Repo.get_by!(PartialAccount, email_hash: email_hash)
  end

  def seed_database() do
    genesis = get_genesis()
    child_a = Poc.create_account("child_a", genesis)
    _grandchild_a = Poc.create_account("grandchild_a", child_a)
    child_b = Poc.create_account("child_b", genesis)
    _grandchild_b = Poc.create_account("grandchild_b", child_b)
    _grandchild_c = Poc.create_account("grandchild_c", child_b)
  end

  def query(origin) do
    import Ecto.Query

    fields = ~w(id self_referral_code referral_code name)a

    non_recursive_term =
      PartialAccount
      |> where([account], account.id == ^origin.id)

    # a = referred/child, b = referrer/parent
    recursive_term =
      PartialAccount
      |> join(:inner, [a], b in "account_tree", on: b.self_referral_code == a.referral_code)

    recursive =
      non_recursive_term
      |> union(^recursive_term)

    # a = referred/child, b = referrer/parent
    "account_tree"
    |> recursive_ctes(true)
    |> with_cte("account_tree", as: ^recursive)
    |> join(:left, [a], b in PartialAccount, on: a.referral_code == b.self_referral_code)
    |> select([a, b], %{
      referred: map(a, ^fields),
      referrer: map(b, ^fields)
    })
    |> Repo.all()
    |> decrypt_name()
  end

  def decrypt_name(relationships) do
    decrypt_function = fn field -> Map.update(field, :name, nil, &Bank.Vault.decrypt!/1) end

    # remove relationships without referrers
    relationships =
      relationships
      |> Enum.reject(fn x -> is_nil(x.referrer) end)

    for %{referred: child, referrer: parent} <- relationships do
      %{
        referred: decrypt_function.(child),
        referrer: if(is_nil(parent), do: nil, else: decrypt_function.(parent))
      }
    end
  end

  def build_graph(relationships) do
    graph = :digraph.new()

    for %{self_referral_code: child, referral_code: parent} <- relationships do
      :digraph.add_vertex(graph, child)
      :digraph.add_vertex(graph, parent)
      :digraph.add_edge(graph, parent, child)
    end

    graph
  end

  def build_network(graph, vertex) do
    children = :digraph.out_neighbours(graph, vertex)

    %{
      used_referral_code: vertex,
      referrals:
        Enum.map(children, fn child ->
          build_network(graph, child)
        end)
    }
  end
end

### database
# Poc.seed_database()
genesis = Poc.get_genesis()

### query
relationships = Poc.query(genesis)

child_b = Repo.get_by!(PartialAccount, email_hash: :crypto.hash(:sha256, "child_b@poc.com"))
sub_tree = Poc.query(child_b)

IO.inspect(sub_tree, label: "sub_tree")
# note that they are not the same

# TODO: put usernames and ids on the query result

### digraph
# graph = Poc.build_graph(relationships)
# {:yes, root} = :digraph_utils.arborescence_root(graph)
# object = Poc.build_network(graph, root)

# IO.inspect(object, label: "object")
