defmodule Bank.Account.BirthDateHelper do
  @moduledoc """
  General use hepler functions.
  """
  @max_customer_age 130
  @min_customer_age 16

  def max_customer_age, do: @max_customer_age
  def min_customer_age, do: @min_customer_age

  def min_max_birth_dates() do
    today = Date.utc_today()
    # TODO: if today == Feb 29 ...
    max_birth_date = Date.new!(today.year - @max_customer_age, today.month, today.day)
    min_birth_date = Date.new!(today.year - @min_customer_age, today.month, today.day)

    %{max: max_birth_date, min: min_birth_date}
  end

  def valid_birth_date_range() do
    %{max: max_birth_date, min: min_birth_date} = min_max_birth_dates()
    Date.range(max_birth_date, min_birth_date)
  end
end
