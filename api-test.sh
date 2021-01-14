#!/usr/bin/env bash

trap "exit" INT TERM ERR
trap "kill 0" EXIT

# ================================================================================
# step 0: prepare the workspace
# ================================================================================

# create an output directory
rm -rf api-docs && mkdir api-docs

# reset the database
mix ecto.reset

# start the server
mix phx.server &

SLEEP=2
echo "Sleeping for $SLEEP seconds" & sleep $SLEEP

# ================================================================================
# step 1: create a user account
# ================================================================================
http post :4000/api/auth cpf=51971486590 password='abc123456' | tee api-docs/step-1.json

# capture the token for later use
TOKEN=$(jq -r '.token' api-docs/step-1.json)
AUTH_HEADER="Authorization:${TOKEN}"

# ================================================================================
# step 2: create a partial account
# ================================================================================
http post :4000/api/accounts/ "${AUTH_HEADER}" | tee api-docs/step-2.json

# capture the account ID for later use
ACCT_ID=$( jq -r '.id' api-docs/step-2.json)

# ================================================================================
# step 3: update some fields, partially
# ================================================================================

echo '{"updates": {"name": "test user", "city": "userland", "state": "stateless", "gender": "other"}}'  \
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"                                         \
    | tee api-docs/step-3a.json

echo '{"updates": {"birth_date": "2000-01-01", "country": "none", "email": "test@user.com"}}'           \
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"                                         \
    | tee api-docs/step-3b.json

echo '{"updates": {"referral_code": "12341234"}}'                                                       \
    | http put :4000/api/accounts/"${ACCT_ID}" "${AUTH_HEADER}"                                         \
    | tee api-docs/step-3c.json

# get the referral code
REFERRAL_CODE=$(jq -r '.self_referral_code' api-docs/step-3c.json  )

# ================================================================================
# step 4: view your referrals (in this case, there will be none)
# ================================================================================
http get :4000/api/referrals/ "${AUTH_HEADER}" | tee api-docs/step-4.json

# ================================================================================
# step 5: create new accounts using our referral code
# ================================================================================
TOKEN_A=$(http post :4000/api/auth cpf='73966184796' password='abc123456' | tee api-docs/step-5a.json | jq -r '.token')
TOKEN_B=$(http post :4000/api/auth cpf='88784747706' password='abc123456' | tee api-docs/step-5b.json | jq -r '.token')

AUTH_A="Authorization:${TOKEN_A}"
AUTH_B="Authorization:${TOKEN_B}"
COMMON=$(echo '{
    "birth_date": "2000-01-01",
    "gender" : "other",
    "city" : "userland",
    "state" : "stateless",
     "country" : "none"
}' | jq ".+ {\"referral_code\": \"$REFERRAL_CODE\"}")

echo $COMMON						\
    | jq '.+ {"name": "ref-a", "email": "a@ref.com"}'	\
    | http post :4000/api/accounts/ "${AUTH_A}"		\
    | tee api-docs/step-5c.json

echo $COMMON						\
    | jq '.+ {"name": "ref-b", "email": "b@ref.com"}'	\
    | http post :4000/api/accounts/ "${AUTH_B}"		\
    | tee api-docs/step-5d.json


# ================================================================================
# step 6: view your referrals again, now with two new referrals
# ================================================================================
http get :4000/api/referrals/ "${AUTH_HEADER}" | tee api-docs/step-6.json

# ================================================================================
# step 7: view referrals from another user
# ================================================================================
http get :4000/api/referrals/ "${AUTH_A}" | tee api-docs/step-7.json
