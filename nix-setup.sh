#!/bin/sh

set -euo pipefail

echo

if [ ! -d "deps" ] || [ ! "$(ls -A deps)" ]; then
    echo "=> Fetching dependencies and building the application..."
    mix do deps.get, compile --verbose
    echo
fi

if [ ! -d "$PGDATA" ]; then
    echo "=> Initialising the database in $PGDATA..."
    initdb --no-locale --encoding=UTF-8
    echo
fi

if [ ! -f "$PGDATA/postmaster.pid" ]; then
    echo "=> Starting PostgreSQL..."
    pg_ctl --log "$PGDATA/server.log" --options="--unix_socket_directories='$PGDATA'" start
    echo
fi

echo "=> Creating the postgres user if necessary.."
createuser postgres --createdb --echo --host=localhost
echo

echo "=> Setting up the database..."
mix ecto.reset
echo

echo "The project setup is complete!"
