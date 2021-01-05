defmodule Bank.Auth.TokenTest do
  use Bank.DataCase, async: true

  alias Bank.Auth.Token

  test "roundtrip" do
    message = "Chancellor on brink of second bailout for banks"
    signed = Token.sign(message)
    {:ok, unsigned} = Token.unsign(signed)
    assert unsigned == message
  end
end
