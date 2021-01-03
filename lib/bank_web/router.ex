defmodule BankWeb.Router do
  use BankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankWeb do
    pipe_through :api

    resources "/auth", AuthController, only: [:create]
    resources "/accounts", AccountController, only: [:create]
  end
end
