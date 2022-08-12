## oAuth Troubles and Debugging in EOS

oAuth can be used for authentication by users accessing EOS via a fuse client.
The example below is based on ScienceBox, with SWAN users accessing EOS through fusex. The oAuth tokens are created by the ocis (ownCloud Infinite Scale) identity provider.

EOS supports custom mapping fields for oAuth since version `4.8.68`. This allows for matching fields returned by the IDP in its json answer to EOS internal user information. See more at [EOS-5013](https://its.cern.ch/jira/browse/EOS-5013).

### Initial configuration
- OpenID Connect Discovery at `https://edocker.cern.ch/.well-known/openid-configuration`
- EOS oAuth configuration
  ```sh
  eos vid enable oauth2
  eos vid set map -oauth2 key:edocker.cern.ch/konnect/v1/userinfo vuid:0
  ```

  Resulting in:
  ```
  [root@sciencebox-mgm-0 /]# eos vid ls
  oauth2:"<pwd>":gid => root
  oauth2:"<pwd>":uid => root
  oauth2:"key:edocker.cern.ch/konnect/v1/userinfo":uid => root
  ```
- EOS reva user configured
  ```sh
  eos -r 0 0 mkdir -p /eos/user/r/reva
  eos -r 0 0 chown 10001:15000 /eos/user/r/reva
  eos -r 0 0 chmod 2700 /eos/user/r/reva
  eos -r 0 0 attr set sys.acl=u:10001:rwx /eos/user/r/reva
  eos -r 0 0 attr set sys.mask=700 /eos/user/r/reva
  eos -r 0 0 attr set sys.allow.oc.sync=1 /eos/user/r/reva
  eos -r 0 0 attr set sys.mtime.propagation=1 /eos/user/r/reva
  eos -r 0 0 attr set sys.forced.atomic=1 /eos/user/r/reva
  eos -r 0 0 attr set sys.versioning=10 /eos/user/r/reva
  eos -r 0 0 access allow user 10001
  ```
- `nscd` and `nslcd` configured to provide EOS with the ability to resolve the username passed in the oAuth token. Local accounts would equally work.


### Example of failed authentication
The following log lines report a wrong mapping of the fields returned by the IDP:
- EOS uses  as `username` the field `sub` from the IDP (which is instead an internal random identifier)
- `federation` and `email` fields are also not mapped properly

As a result, the oAuth user is mapped to `99:99` (`nobody`) and the authentication fails, resulting in permission denied
```
211102 11:15:48 INFO  OAuth:106                      token='eyJhbGciOiJQUzI1NiIs...' claims=[ kc.provider="identifier-ldap" kc.isAccessToken=true kc.identity={"kc.i.dn":"reva","kc.i.id":"cn=reva,ou=users,dc=example,dc=org","kc.i.un":"reva"} aud="swan-qa" jti="uJL0xHJAmNJ9z2HgSdOcVQFOviAE6XSV" exp=1635852122 iat=1635851522 sub="bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect" kc.authorizedScopes=["email","profile","offline_access","openid"] iss="https:\/\/sciencebox.cernbox.cern.ch"  ] 
211102 11:15:48 INFO  OAuth:253                      username='bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect' name='reva' federation='' email='' expires=1635852122 
211102 11:16:06 time=1635851766.226921 func=Validate                 level=INFO  logid=static.............................. unit=mgm@sciencebox-mgm-0.sciencebox-mgm.default.svc.cluster.local:1094 tid=00007f1deb5f6700 source=OAuth:106                      tident= sec=(null) uid=99 gid=99 name=- geo="" token='eyJhbGciOiJQUzI1NiIs...' claims=[ kc.provider="identifier-ldap" kc.isAccessToken=true kc.identity={"kc.i.dn":"reva","kc.i.id":"cn=reva,ou=users,dc=example,dc=org","kc.i.un":"reva"} aud="swan-qa" jti="uJL0xHJAmNJ9z2HgSdOcVQFOviAE6XSV" exp=1635852122 iat=1635851522 sub="bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect" kc.authorizedScopes=["email","profile","offline_access","openid"] iss="https:\/\/sciencebox.cernbox.cern.ch"  ]
211102 11:16:06 time=1635851766.226978 func=Handle                   level=INFO  logid=static.............................. unit=mgm@sciencebox-mgm-0.sciencebox-mgm.default.svc.cluster.local:1094 tid=00007f1deb5f6700 source=OAuth:253                      tident= sec=(null) uid=99 gid=99 name=- geo="" username='bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect' name='reva' federation='' email='' expires=1635852122
211102 11:16:06 time=1635851766.227164 func=FSctl                    level=ERROR logid=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx unit=mgm@sciencebox-mgm-0.sciencebox-mgm.default.svc.cluster.local:1094 tid=00007f1deb5f6700 source=Fsctl:242                      tident=<single-exec> sec=oauth2 uid=2 gid=2 name=daemon geo="" user access restricted - unauthorized identity vid.uid=2, vid.gid=2, vid.host="[::ffff:172.17.0.5]", vid.tident="AAAAAAAE.25609:405@[::ffff:172.17.0.5]" for path="/proc/user/" user@domain="daemon@17.0.5]"
211102 11:16:06 time=1635851766.227199 func=Emsg                     level=ERROR logid=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx unit=mgm@sciencebox-mgm-0.sciencebox-mgm.default.svc.cluster.local:1094 tid=00007f1deb5f6700 source=XrdMgmOfs:1207                 tident=<single-exec> sec=      uid=0 gid=0 name= geo="" Unable to give access - user access restricted - unauthorized identity used ; Permission denied
```


### Debugging from the fuse client
The fuse client helps troubleshooting by manually attempting to connect to the EOS MGM.

In what follows, the fuse client was installed in the singleuser image used to spawn containers for users sessions.
All the environment variables and paths refer to the singleuser environment
- Validation of oAuth token:
  ```
  curl -L  -H "Authorization: Bearer $ACCESS_TOKEN" $OAUTH_INSPECTION_ENDPOINT
  {
    "email_verified": false,
    "family_name": "reva",
    "name": "reva",
    "preferred_username": "reva",
    "sub": "bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect"
  }
  ```
- Preparation of the OAUTH2 file used by EOS client:
  ```sh
  export OAUTH2_FILE=/tmp/eos_oauth.token
  export OAUTH2_TOKEN="FILE:$OAUTH2_FILE"
  echo -n oauth2:$ACCESS_TOKEN:$OAUTH_INSPECTION_ENDPOINT >& $OAUTH2_FILE
  chown -R $USER:$USER $OAUTH2_FILE
  chmod 600 $OAUTH2_FILE
  ```
- Output of working `eos reconnect`
  ```
  $ eosxd get eos.reconnect /eos
  	===== Retrieve process snapshot for pid=3723331, uid=1000, gid=1000, reconnect=1 =====
  	-- /proc/3723331/root lookup
  	  jail identifier: st_dev=1048653, ino=76891320 -- DIFFERENT jail than eosxd!
  	Found cached entry in ProcessCache (AAAAAAAQ - 4), but reconnecting as requested
  	execveAlarm = 0, PF_FORKNOEXEC = 0, checkParentFirst = 0
  	-- Attempting to discover bound identity based on environment variables
  	  -- Attempting to produce BoundIdentity out of process environment, pid=3723331
  		Succeeded in retrieving environment variables for pid=3723331
  		Found OAUTH2_TOKEN: /tmp/eos_oauth.token, need to validate
  		-- Attempt to translate UserCredentials -> BoundIdentity
  		  Cache entry UserCredentials -> BoundIdentity already exists (AAAAAAAQ - 4) - invalidating
  		  Credential file must be copied - path: /var/cache/eos/fusex/credential-store/eos/eos-fusex-uuid-store-14c57ed9-0ec5-4cb3-84ca-88ab383c5d1a
  		  UserCredentials registerSSS (AAAAAAAU)
  		  Endorsement (oauth2:eyJhbGciOiJQUzI1NiIsImtpZCI6IiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzd2FuIiwiZXhwIjoxNjQ4MDcxOTIzLCJqdGkiOiJfdnFhVUcyazJNOGpld1BtZC04OXRDdi05Z01HMWhPZyIsImlhdCI6MTY0ODA0MzEyMywiaXNzIjoiaHR0cHM6Ly9zY2llbmNlYm94LmNlcm5ib3guY2Vybi5jaCIsInN1YiI6Ilh0U2lfbWl5V1NCLXBrdkdueFBvQzVBNGZsaWgwVUNMZ3ZVN2NMd2ptakNLWDdGWW4ySFdrNnJSQ0V1eTJHNXFBeV95TVFjX0ZLOWFORmhVTXJYMnBRQGtvbm5lY3QiLCJrYy5pc0FjY2Vzc1Rva2VuIjp0cnVlLCJrYy5hdXRob3JpemVkU2NvcGVzIjpbInByb2ZpbGUiLCJvZmZsaW5lX2FjY2VzcyIsIm9wZW5pZCIsImVtYWlsIl0sImtjLmlkZW50aXR5Ijp7ImtjLmkuZG4iOiJlaW5zdGVpbiIsImtjLmkuaWQiOiJjbj1laW5zdGVpbixvdT11c2VycyxkYz1leGFtcGxlLGRjPW9yZyIsImtjLmkudW4iOiJlaW5zdGVpbiJ9LCJrYy5wcm92aWRlciI6ImlkZW50aWZpZXItbGRhcCJ9.aWn-w4PdYBCWaDxnYZ_oKbOD_P39B1PnSiIh53XxrTVWILJSLiqYM6OG6SKrppPcXQrxDBdfcOFKALV7-3XNMPmNJkCz0395T7iNNvU3hARbwfndvtbl9_OrHLFwl39F6sqYUYwzNbslxYhJRtGPFK6dge9sUVKAeqq-k3vZXv2xmnF0GeoVumknBPrV5yKzfU8hUqxXGAp4rivA5H9MakAbIAbj1qhkyUgKc3EScgEB-3byMcUtB21WoHBbRQ_sKOqtZJFQglk9SyR0M-G5neAydu87kngpys9BDa6MXLS2UemJ9HJ4Zcg71CilB0hKs3q6RPkhL931Yevt0sxKSw:sciencebox.cernbox.cern.ch/konnect/v1/userinfo)
  
  	===== BOUND IDENTITY: =====
  	Login identifier: AAAAAAAU - 5
  	oauth2: /tmp/eos_oauth.token for uid=1000, gid=1000, under jail identifier: st_dev=1048653, ino=76891320
  	mtime: 1648043262.149861432
  	intercepted path: /var/cache/eos/fusex/credential-store/eos/eos-fusex-uuid-store-14c57ed9-0ec5-4cb3-84ca
  ```
- The content of files `/tmp/eos_oauth.token` in the singeuser container and `/var/cache/eos/fusex/credential-store/eos/eos-fusex-uuid-store-14c57ed9-0ec5-4cb3-84ca` (or whatever uuid store) in the fusex container must match.


### Fixing username mapping in EOS
Since version `4.8.68`, the EOS username can be mapped to an arbitrary fields of the IDP response with the environment variable `EOS_MGM_OIDC_MAP_FIELD` (see [EOS-5013](https://its.cern.ch/jira/browse/EOS-5013)).
Currently, in ScienceBox with the ocis IDP and self-signed certificates, we use:
- `EOS_MGM_OIDC_INSECURE=true` to accept bad certificates
- `EOS_MGM_OIDC_MAP_FIELD="preferred_username"` to maps EOS username to the `preferred_username` of the IDP response

...ultimately fixing the authentication problem with oAuth
- BAD:
  ```
  220323 12:50:58 INFO  OAuth:106                      token='eyJhbGciOiJQUzI1NiIs...' claims=[ kc.provider="identifier-ldap" kc.isAccessToken=true kc.identity={"kc.i.dn":"reva","kc.i.id":"cn=reva,ou=users,dc=example,dc=org","kc.i.un":"reva"} aud="swan" jti="4oIkT103IOiKu0B-AH8PVfw6pJUTTiJz" exp=1648068618 iat=1648039818 sub="bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect" kc.authorizedScopes=["openid","email","profile","offline_access"] iss="https:\/\/sciencebox.cernbox.cern.ch"  ] 
  220323 12:50:58 INFO  OAuth:253                      username='bWMsy-xSN7EHs8qz-zqLreSI3tXZlPc_zM9DukTpcTPHVJXFW6G-7nLggvQt4UvNKrwUtPI78jkON9RkziN2dA@konnect' name='reva' federation='' email='' expires=1648068618 
  ```
- GOOD:
  ```
  220323 14:50:54 INFO  OAuth:106                      token='eyJhbGciOiJQUzI1NiIs...' claims=[ kc.provider="identifier-ldap" kc.isAccessToken=true kc.identity={"kc.i.dn":"reva","kc.i.id":"cn=reva,ou=users,dc=example,dc=org","kc.i.un":"reva"} aud="swan" jti="cw8R6sCtSfJeIJzX7dy1gyjcmpDKjwfb" exp=1648075770 iat=1648046970 sub="XtSi_miyWSB-pkvGnxPoC5A4flih0UCLgvU7cLwjmjCKX7FYn2HWk6rRCEuy2G5qAy_yMQc_FK9aNFhUMrX2pQ@konnect" kc.authorizedScopes=["offline_access","openid","email","profile"] iss="https:\/\/sciencebox.cernbox.cern.ch"  ] 
  220323 14:50:54 INFO  OAuth:258                      username='reva' name='reva' federation='' email='' expires=1648075770 
  ```
