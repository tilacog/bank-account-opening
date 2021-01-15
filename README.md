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

The system will then  listen for connectons on port 4000.

## Interacting with the API



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

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details
on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on
this repository](https://github.com/your/project/tags).

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated
in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
