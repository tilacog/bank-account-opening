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

    fields = ~w(id self_referral_code referral_code)a

    non_recursive_term =
      PartialAccount
      |> where([account], account.id == ^origin.id)
      |> select(^fields)

    recursive_term =
      PartialAccount
      |> join(:inner, [b], a in "account_tree", on: a.self_referral_code == b.referral_code)
      |> select(^fields)

    recursive =
      non_recursive_term
      |> union(^recursive_term)

    PartialAccount
    |> recursive_ctes(true)
    |> with_cte("account_tree", as: ^recursive)
    |> select([a], map(a, ^fields))
    |> Repo.all()
  end

  defp build_graph(relationships) do
    graph = :digraph.new()

    for %{self_referral_code: child, referral_code: parent} <- relationships do
      :digraph.add_vertex(graph, child)
      :digraph.add_vertex(graph, parent)
      :digraph.add_edge(graph, parent, child)
    end

    graph
  end

  defp build_tree(graph, vertex) do
    children = :digraph.out_neighbours(graph, vertex)

    %{
      name: vertex,
      children:
        Enum.map(children, fn child ->
          build_tree(graph, child)
        end)
    }
  end
end
