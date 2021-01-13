with recursive referrals as (

     -- non-recursive term
     select id, self_referral_code, referral_code, state
     from partial_accounts
     where id = 1 -- try other ids, such as 2 or 4

     union

     -- recursive term
     select b.id, b.self_referral_code, b.referral_code, b.state
     from partial_accounts b
     inner join referrals as a
     	   on a.self_referral_code = b.referral_code
)

select * from referrals
order by id
