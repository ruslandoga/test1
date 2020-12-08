- [ ] geo search stuff - given a coordinate and a radius, find geohash prefix for searching in the users table

say for user u1 we get 10 geohashes, and 18-30 age filter, then we need to issue 120 parallel requests for the users

and then filter the users `u` who have `u1.age in u.age_filter_min..u.age_filter_max` and `u1.position in u.distance_filter` and `u1.gender == u.gender_filter`

after that we need to get the most likable candidates for `u1` (TODO)

- [ ] last active -> also affects users search
- [ ] setup demo map with other users and geohash search
- [ ] finish all of the below

```
- [x] users:{gender}:{last_active}:{age}:{geohash}:{user_id} -> {filters}
- [x] users:{id} -> {username,etc.}
- [x] filters:{id} -> {age_filter,etc.}

- action_log:{user_id}:{timestamp} -> {action (updated profile, etc.)}

- sessions:{user_id}:{timestamp_logged_in}:{device} -> {}

- auth:password:{user_id} -> password_hash
- auth:facebook:{facebook_id} -> token
- auth:instagram:{instagram_id} -> token
- auth:sms:{phone_number}:{otp_code}

- likes:{from_user_id}:{to_user_id}
- passes:{from_user_id}:{to_user_id}
- seen:{swiper_id}:{swipee_id}

- matches:{user_id}:{user_id} (one for each user)
- matches:{user_id}:{user_id}

- reports:{user_id}:{timestamp} -> {user_id,cause,text}
- reports:{timestamp}:{user_id} -> {user_id,cause,text}

- messages:{from_user_id}:{to_user_id}:{timestamp} -> {text}
```

- [ ] add web api
- [ ] deploy
- [ ] setup cd
