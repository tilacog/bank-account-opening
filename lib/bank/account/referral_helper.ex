defmodule Bank.Account.ReferralHelper do
  alias Bank.Account.PartialAccount
  alias Bank.Repo

  def build_referral_tree(origin) do
    relationships = query(origin)
    graph = build_graph(relationships)
    {:yes, root} = :digraph_utils.arborescence_root(graph)
    build_tree(graph, root)
  end

  defp query(origin) do
    import Ecto.Query

    fields = ~w(name)a

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
    |> select([a, b], %{referred: map(a, ^fields), referrer: map(b, ^fields)})
    |> Repo.all()
    |> decrypt_name()
  end

  defp decrypt_name(relationships) do
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

  defp build_graph(relationships) do
    graph = :digraph.new()

    for %{referred: child, referrer: parent} <- relationships do
      :digraph.add_vertex(graph, child)
      :digraph.add_vertex(graph, parent)
      :digraph.add_edge(graph, parent, child)
    end

    graph
  end

  defp build_tree(graph, vertex) do
    %{
      referrals:
        :digraph.out_neighbours(graph, vertex)
        |> Enum.map(fn child -> build_tree(graph, child) end)
    }
    # removing the :id and :self_referral_code improve readability

    |> Map.merge(vertex)
  end
end
