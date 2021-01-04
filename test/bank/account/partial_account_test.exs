defmodule Bank.Account.PartialAccountTest do
  use Bank.DataCase, async: true
  alias Bank.Account.PartialAccount

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
      ["invalid", "20200101", "2020/01/01", "2020-02-31"],
      ["is invalid"],
      :birth_date
    )
  end

  test "birth date must be valid" do
    test_good_inputs(["2020-01-01", "1990-12-31"], :birth_date)
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
end