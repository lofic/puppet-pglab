Set a working lab for PostgreSQL.

Work in progress.

Todo :

* provide a wrapper to add some users, grants, cfg options, and hba rules

Needs the module puppetlabs/postgresql.

Needs some hiera parameters.

With yaml :

```
---
pglab::pgversion: '9.6'
postgresql::repo::version: '9.6'
#pglab::pgversion: '10'
#postgresql::repo::version: '10'
postgresql::server::listen_addresses: '*'
postgresql::server::ip_mask_allow_all_users: '0.0.0.0/0'
postgresql::server::ip_mask_deny_postgres_user: '0.0.0.0/32'
```

Deploy automatically some databases set with hiera hashes, for example :

```
---
pglab::databases:
    mydb:
        user: 'mydbuser'
        password : ...
    pgbench:
        user: 'pgbench'
        password: ...
```

Use a hiera eyaml backend for the passwords.

