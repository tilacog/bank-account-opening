defmodule Bank.Auth.Token do
  @salt "auth-token"
  @sep "."

  @doc """
  Signs the given string.
  """
  def sign(value) do
    signature = get_signature(value)
    value <> @sep <> signature
  end

  @doc """
  Unsigns the given string.
  """
  def unsign(signed_value) do
    with true <- String.contains?(signed_value, @sep),
         [value, signature] <- String.split(signed_value, @sep),
         true <- verify_signature(value, signature) do
      {:ok, value}
    else
      _error -> {:error, :bad_signature}
    end
  end

  # Returns the signature for the given value.
  def get_signature(value) do
    key = Application.get_env(:bank, BankWeb.Endpoint)[:secret_key_base]
    :crypto.hmac(:sha256, key <> @salt, value) |> Base.encode64()
  end

  # Verifies the signature for the given value.
  # Use constant-time comparison algorithm to prevent timing attacks.
  defp verify_signature(value, signature) do
    our_signature = get_signature(value)
    SecureCompare.compare(our_signature, signature)
  end
end
