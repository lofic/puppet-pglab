# Macro to set (create, ACL...) some databases

define pglab::setdb($user, $password) {

    postgresql::server::db { $title:
        user     => $user,
        password => postgresql_password( $user, $password),
    }

    $mu=$pglab::monitoringu

    # ACL for the user on the database
    postgresql::server::pg_hba_rule { "host ACL for ${user} on ${title}":
      type        => 'host',
      database    => $title,
      address     => '0.0.0.0/0',
      user        => $user,
      auth_method => 'md5',
      order       => '001'
    }

    postgresql::server::pg_hba_rule { "local ACL for ${user} on ${title}":
      type        => 'local',
      database    => $title,
      user        => $user,
      auth_method => 'md5',
      order       => '001'
    }

    # Grant connect to monitoring
    postgresql::server::database_grant { "${mu}-${title}":
      privilege => 'CONNECT',
      db        => $title,
      role      => $mu,
      require   => Postgresql::Server::Db[ $title ],
    }


}
