defmodule Bank.Account.PartialAccountTest do
  use Bank.DataCase, async: true
  alias Bank.Account.PartialAccount
  alias Bank.Account
  alias Bank.Account.BirthDateHelper

  test "encrypt fields changeset" do
    email = "decripted@test.com"
    name = "john doe"
    birth_date = "2000-01-01"

    encrypted =
      %PartialAccount{}
      |> Ecto.Changeset.cast(
        %{email: email, name: name, birth_date: birth_date},
        [:email, :name, :birth_date]
      )
      |> PartialAccount.encrypt_field(:email)
      |> PartialAccount.encrypt_field(:name)
      |> PartialAccount.encrypt_field(:birth_date)

    assert Bank.Vault.decrypt!(encrypted.changes.email) == email
    assert Bank.Vault.decrypt!(encrypted.changes.name) == name
    assert Bank.Vault.decrypt!(encrypted.changes.birth_date) == birth_date
  end

  test "email can't be invalid" do
    changeset = PartialAccount.changeset(%PartialAccount{}, %{email: "invalid"})
    assert %{email: ["is not a valid email"]} = errors_on(changeset)
  end

  test "email must be valid" do
    assert PartialAccount.changeset(%PartialAccount{}, %{email: "foo@bar.com"}).valid?
  end

  test "gender must be male|female|other" do
    test_good_inputs(~w(male female other), :gender)
  end

  test "gender can't be invalid" do
    test_bad_inputs(["m", "f", "o", "men", "woman", "???"], ["is invalid"], :gender)
  end

  test "birth date can't be invalid" do
    test_bad_inputs(
      ["invalid", "20200101", "2020/01/01"],
      ["invalid date format"],
      :birth_date
    )

    %{max: max_birth_date, min: min_birth_date} = BirthDateHelper.min_max_birth_dates()
    # shift dates out of bounds
    max_birth_date = Date.add(max_birth_date, -1)
    min_birth_date = Date.add(min_birth_date, 1)

    test_bad_inputs(
      [max_birth_date, min_birth_date] |> Enum.map(&Date.to_iso8601(&1)),
      [
        "age must be between #{BirthDateHelper.min_customer_age()} and #{
          BirthDateHelper.max_customer_age()
        } years old"
      ],
      :birth_date
    )
  end

  test "birth date must be valid" do
    test_good_inputs(["2000-01-01", "1990-12-31"], :birth_date)
  end

  test "referral_code can't be invalid" do
    test_bad_inputs(["123", "456", "1234560"], ["should be 8 character(s)"], :referral_code)
    test_bad_inputs(["invalid!", "1234567Y"], ["must be numeric"], :referral_code)
  end

  test "referral_code must be valid" do
    test_good_inputs(["11223344", "12341234", "43211234", "56473829"], :referral_code)
  end

  # Helper function to check expected error messages for a list of bad inputs.
  defp test_bad_inputs(inputs, expected_errors, key) do
    for input <- inputs do
      changeset = PartialAccount.changeset(%PartialAccount{}, %{key => input})
      assert %{^key => ^expected_errors} = errors_on(changeset)
    end
  end

  # Helper function to assert a changeset is valid for a list of good inputs.
  defp test_good_inputs(inputs, key) do
    for input <- inputs do
      assert PartialAccount.changeset(%PartialAccount{}, %{key => input}).valid?
    end
  end

  test "can use a good referral code" do
    user = api_user_fixture()
    result = Account.create_partial_account(user, %{referral_code: genesis_referral_code()})
    assert {:ok, _partial_account} = result
  end

  test "can't use a bad referral code" do
    user = api_user_fixture()
    result = Account.create_partial_account(user, %{referral_code: "00110011"})
    assert {:error, %Ecto.Changeset{} = invalid_changeset} = result
    refute invalid_changeset.valid?

    assert {"does not exist",
            [
              {:constraint, :foreign},
              {:constraint_name, "partial_accounts_referral_code_fkey"}
            ]} = invalid_changeset.errors[:referral_code]
  end

  @valid_changes %{
    name: "foo",
    email: "foo@bar.com",
    birth_date: "2000-01-01",
    gender: "other",
    city: "AB",
    state: "CD",
    country: "EF",
    referral_code: "12213443"
  }

  test "complete account will have :self_referral_code field and :completed status" do
    partial_account = PartialAccount.changeset(%PartialAccount{}, @valid_changes)
    assert partial_account.changes.self_referral_code != nil
  end

  test "partial account won't be complete without all required fields" do
    # omitting a single field will prevent the changeset to be complete
    Map.keys(@valid_changes)
    |> Enum.each(fn field ->
      incomplete_changes = Map.delete(@valid_changes, field)
      partial_account = PartialAccount.changeset(%PartialAccount{}, incomplete_changes)

      refute Map.has_key?(partial_account, :referral_code)
    end)
  end
end
