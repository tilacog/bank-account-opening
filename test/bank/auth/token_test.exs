defmodule Bank.Auth.TokenTest do
  use Bank.DataCase, async: true

  alias Bank.Auth.Token

  test "roundtrip" do
    message = "Chancellor on brink of second bailout for banks"
    signed = Token.sign(message)
    {:ok, unsigned} = Token.unsign(signed)
    assert unsigned == message
  end

  test "encodes the message in Base64" do
    message = "Rosebud"
    signed = Token.sign(message)
    [head, _] = String.split(signed, ".")
    assert message == Base.decode64!(head)
  end
end
