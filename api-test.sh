#!/usr/bin/env bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

# reset the database
mix ecto.reset

# start the server
mix phx.server &

export SLEEP=2
echo "Sleeping for $SLEEP seconds" & sleep $SLEEP

# step 1: create a user account
http post :4000/api/auth cpf=51971486590 password='abc123456' | tee api-docs.step-1.json

# capture the token for later use
export TOKEN=$(grep '"status"' api-docs.step-1.json | jq ".token" | tr -d '"')
export AUTH_HEADER="Authorization:${TOKEN}"

# step 2: create a partial account
http post :4000/api/accounts/ "${AUTH_HEADER}" | tee api-docs.step-2.json

# capture the account ID for later use
export ACCT_ID=$(grep '"status"' api-docs.step-2.json | jq ".id" )

# step 3: update some fields, partially

echo '{"updates": {"name": "test user", "city": "userland", "state": "stateless", "gender": "other"}}'	\
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"						\
    | tee api-docs.step-3a.json

echo '{"updates": {"birth_date": "2000-01-01", "country": "none", "email": "test@user.com"}}'		\
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"						\
    | tee api-docs.step-3b.json

echo '{"updates": {"referral_code": "12341234"}}'							\
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"						\
    | tee api-docs.step-3c.json

# step 4: view your referrals (in this case, there will be none)
http get :4000/api/referrals/ "${AUTH_HEADER}" | tee api-docs.step-4.json
