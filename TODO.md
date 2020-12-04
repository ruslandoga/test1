- [ ] geo search stuff - given a coordinate and a radius, find geohash prefix for searching in the users table

say for user u1 we get 10 geohashes, and 18-30 age filter, then we need to issue 120 parallel requests for the users

and then filter the users `u` who have `u1.age in u.age_filter_min..u.age_filter_max` and `u1.position in u.distance_filter` and `u1.gender == u.gender_filter`

after that we need to get the most likable candidates for `u1` (TODO)

```
table:
users:{gender}:{age}:{geohash}:{user_id} -> {age_filter: [min,max], distance_filter: n, gender_filter}
```

- [ ] add api

```
  - updates:(user_id,timestamp) -> {...}
  - auth:password:(user_id) -> password_hash
  - auth:facebook:(facebook_id) -> token
  - auth:instagram:(instagram_id) -> token
  - auth:sms:(phone_number,otp_code)
  - matches:(user_id,user_id)
  - reports:(user_id) -> {user_id,cause,text}
  - likes:(user_id,user_id)
  - passes:(user_id,user_id)
  - messages:(from_user_id,to_user_id,timestamp) -> {text,likes}
```

- [ ] deploy api
- [ ] setup cd
