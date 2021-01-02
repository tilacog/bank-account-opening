{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [ elixir_1_11 git postgresql_13 ];
  LANG="C.utf8";
  # Put the PostgreSQL databases in the project diretory.
  shellHook = ''
      export PGDATA="$PWD/.db_data"
    '';
}
