{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [ elixir_1_11 git postgresql_13 httpie jq ];
  LANG="C.utf8";
  CLOAK_SECRET_KEY="a+gYgCLyXaSXJjc+O3raTanCOUrP/PsuL/dWrzSzzTk=";
  # Put the PostgreSQL databases in the project diretory.
  shellHook = ''
      export PGDATA="$PWD/.pg_data"
    '';
}
