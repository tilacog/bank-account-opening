# Bank Account Opening

> RESTful API to open accounts with partial updates while keeping sensitive data encrypted at rest.

This project is a HTTP JSON api/server made with Elixir and Phoenix Framework that handles incoming
requests for opening bank accounts. Account fields can be sent in across several requests until all
required fields are filled. Authorization is enforced on all routes.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for
development and testing purposes. See deployment for notes on how to deploy the project on a live
system.

### Prerequisites

This project depends on the following software to be installed and executed:

- git
- Elixir 1.11
- PostgreSQL 13

For integration tests, you will also need:

- [httpie](https://httpie.org/)
- [jq](https://stedolan.github.io/jq/)

An enviroment variable named `CLOAK_SECRET_KEY` must be populated with a secret and secure key for
the encryption engine to work properly.

The recommended and easiest way to run this software is using
`[nix](https://nixos.org/guides/install-nix.html)` to provision all required packages in an isolated
environment.

A `shell.nix` file is present for automatically seting up the required environment and isolating it
with a single command. If you choose to use it, just run this command at the project root directory:

```
$ nix-shell --pure
```

The command above will build or download all required dependencies if they’re not already in your Nix
store, and then start a Bash shell in which all necessary environment variables are set.
search paths) are set.

### Installing

Use `git` to clone the project and `cd` into its directory.

```
$ git clone git@github.com:tilacog/bank-account-opening.git
$ cd bank-account-opening
```

If `nix` is present, invoke the Nix shell:

```
$ nix-shell --pure
```

Then setup the environment calling the `setup.sh` script.

```
$ chmod +x setup.sh
$ ./setup.sh
```

The `setup.sh` script will:

- Fetch the project dependencies with `mix`.
- Initialize the postgreSQL database.
- Setup the database with `ecto`

To run the server, call the command:

```
$ mix phx.server
```

The system will then listen for connectons on port 4000.

## Interacting with the API

The API revolves arround two resources:

- `ApiUsers`, which contains the user's `cpf` and `password` fields,
  both encrypted at rest.
- `PartialAccounts`, wiche contains all required fields for the
  _(partial)_ account creation process:
  - `name` _(encrypted at rest)_
  - `email` _(encrypted at rest)_
  - `birth_date` _(ISO 8601 string, encrypted at rest)_
  - `gender` _(male | female | other)_
  - `city`
  - `state`
  - `country`
  - `referral_code` _(an 8 digit code)_

To create and update a `PartialAccount`, an user must first create its
`ApiUser` and retrieve an **authentication token**, which will be used
across all other requests to the API.

### Step 1: creating an `api_user` account

To create an user account and fech an authentication token, we must
send a `POST` request to the `/api/auth` endpoint with the following
JSON payload::

```javascript
{
	"cpf": "51971486590",
	"password": "super-secret-password"
}
```

The server will check if:

- The given `cpf` is a valid Brazilian CPF number.
- The CPF isn't already being used.
- The `password` field length is at least 6 and at most 100 characters
  long.

If all of those conditions are met, the server will return a JSON
response with a `201` status code containing the authorization token
and a success message:

```javascript
{
  "status": "success",
  "token": "NTE5NzE0ODY1OTA=.E7CTZyp01gvOJ5EnJUZcsJrJdv4qNHiNnMP7giyXAVM="
}
```

Any errors will also be informed to the api user using the same
interface.

### Step 2: creating a (partial) bank account

With the authentication tokn at hand, we can now place it in the
`Authorization` header send a `POST` request to the `/api/accounts/`
to create a bank account for our api user.

```javascript
{
  "birth_date": null,
  "city": null,
  "country": null,
  "email": null,
  "gender": null,
  "id": 2,
  "name": null,
  "referral_code": null,
  "state": null,
  "status": "incomplete"
}
```

It is not necessary to inform any of the account fields for the
request to be successful, but the account will remain with its
`incomplete` status until all fields have valid values.

Further `PATCH` or `PUT` requests can be sent to the
`/api/accounts/<account_id>` endpoint to update the account fields.

If we were to provide all the fields in three sequential requests:

#### Request 1: Provide `name`, `city`, `state` and `gender` fields

The `PUT`/`PATCH` request should contain the informed fields inside an `updates` object.

```javascript
"updates": {
	"name": "test user",
	"city": "userland",
	"state": "stateless",
	"gender": "other"
}
```

And the response will contain the updated `PartialAccount` resource:

```javascript
{
  "birth_date": null,
  "city": "userland",
  "country": null,
  "email": null,
  "gender": "other",
  "id": 2,
  "name": "test user",
  "referral_code": null,
  "state": "stateless",
  "status": "incomplete"
}

```

Note that the `status` field is still `incomplete` because there are still missing fields.

#### Request 2: Provide `birth_date`, `country`, `email` and `email` fields

The second payload for our `PUT`/`PATCH` request will include some of
the missing fields:

```javascript
"updates": {
	"birth_date": "2000-01-01",
	"country": "none",
	"email": "test@user.com"
}
```

The response still tells us that the account status is `incomplete`:

```javascript
{
  "birth_date": "2000-01-01",
  "city": "userland",
  "country": "none",
  "email": "test@user.com",
  "gender": "other",
  "id": 2,
  "name": "test user",
  "referral_code": null,
  "state": "stateless",
  "status": "incomplete"
}
```
#### Request 2: Provide `referral_code` and obtain a `complete` account

In the third and final `PUT`/`PATCH` request, we'll provide the last
missing field, the `referral_code`.

For this request to be valid, the `referral_code` must be provided from
another **completed** account. Since this requirement defines a tree
structure,bthe application database is seeded with a *genesis* account for us to borrow its referral code.

The referral code for the *genesis account* is `12341234`.

```javascript
"updates": { "referral_code": "12341234" }
```

And the server informs us that the account is finally `complete`:

```javascript
{
  "birth_date": "2000-01-01",
  "city": "userland",
  "country": "none",
  "email": "test@user.com",
  "gender": "other",
  "id": 2,
  "name": "test user",
  "referral_code": "12341234",
  "self_referral_code": "55607857",
  "state": "stateless",
  "status": "complete"
}

```

Note that besides being marked as complete, our account now have its
own referral code in the `self_referral_code` field to be sent as an
invitation for new users to create their own accounts.

### Step 3: View the referral tree

When the account creation process is finished, we can send an
authenticated `GET` request to the `/api/referrals/` endpoint to
obtain a JSON containing the referral tree scoped at the current user:

```javascript
{
  "name": "genesis",
  "referrals": [
    {
      "name": "test user",
      "referrals": []
    }
  ]
}
```

We can see our referrer, the *genesis* account, and our own account
with no referrals. If two new accounts were to be created *(and
completed)* using our own referral code, that response would contain
their names and referrals, like the following example:

```javascript
{
  "name": "genesis",
  "referrals": [
    {
      "name": "test user",
      "referrals": [
        {
          "name": "other user - a",
          "referrals": []
        },
        {
          "name": "other user - b",
          "referrals": []
        }
      ]
    }
  ]
}

```

Since that endpoint is scoped on the authenticated user, if we reach
that view from another user *(let's say, the `other user - a`)*, the
response would only contain its referrer *(our original `test user`)*
and its referrals:

```javascript
{
  "name": "test user",
  "referrals": [
    {
      "name": "ref-a",
      "referrals": []
    }
  ]
}
```

## Running the tests

To run the automated test suite, run the command:

```
$ mix test
```

To run the end to end tests, run the script `api-test.sh`:

```
$ chmod +x api-tests.sh
$ ./api-tests.sh
```

All the API responses from the end to end tests will be stored in the
`./api-docs/` directory, for reference.

## Contributing

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of
conduct, and the process for submitting pull requests.

## Authors

- [tilacog](https://github.com/tilacog) - *Initial work*


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
