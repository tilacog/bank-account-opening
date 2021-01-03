defmodule BankWeb.AuthControllerTest do
  use BankWeb.ConnCase

  test "require cpf and password ", %{conn: conn} do
    conn = post(conn, Routes.auth_path(conn, :create))
    body = json_response(conn, 422)
    assert "can't be blank" in body["errors"]["cpf"]
    assert "can't be blank" in body["errors"]["password"]
  end
end
