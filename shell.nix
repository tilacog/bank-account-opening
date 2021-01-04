{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [ elixir_1_11 git postgresql_13 ];
  LANG="C.utf8";
  CLOAK_SECRET="bezq7tbGMqgn9QLkuGJmFNfXec7jOLTKHz1bI0bYTHw=";
  # Put the PostgreSQL databases in the project diretory.
  shellHook = ''
      export PGDATA="$PWD/.db_data"
    '';
}
