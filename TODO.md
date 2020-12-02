- [ ] setup ci
- [ ] add api

```
  - users:(user_id,profile) -> {username::string,lat,lon,job,school}
  - users:filters:(user_id) -> {age_filter_min,gender_filter,gender,age_filter_max,distance_filter}
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
