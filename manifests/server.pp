# Lab for PostgreSQL

class pglab::server {

    $pgver = $pglab::pgversion
    $pgsuffix = regsubst($pgver,'\.','')
    $pgbase   = $pglab::pgbase

    File {
        ensure => present,
        owner  => 'postgres',
        group  => 'postgres',
        mode   => '0755'
    }

    file { $pgbase :
        ensure => directory,
        owner  => 'root',
        group  => 'root',
    }

    if  $::osfamily == 'RedHat' {
        $manage_package_repo = false
        require 'pglab::repo'
        $reqs = [ File[$pgbase], Yumrepo["PostgreSQL ${pgver}"] ]
    } else {
        $manage_package_repo = true
        $reqs = File[$pgbase]
    }

    class { 'postgresql::globals':
        version             => $pgver,
        manage_package_repo => $manage_package_repo,
        datadir             => "${pgbase}/data",
        service_name        => "postgresql-${pgver}",
        createdb_path       => "/usr/pgsql-${pgver}/bin/createdb",
        initdb_path         => "/usr/pgsql-${pgver}/bin/initdb",
        psql_path           => "/usr/pgsql-${pgver}/bin/psql",
        server_package_name => "postgresql${pgsuffix}-server",
        client_package_name => "postgresql${pgsuffix}",
        require             => $reqs,
    }

    class { 'postgresql::server':
        require => File[$pgbase],
    }

    # Provide pgbench
    package { "postgresql${pgsuffix}-contrib" :
        ensure  => present,
        require => Class['postgresql::server'],
    }

    # Monitoring user
    $mu = $pglab::monitoringu
    $mp = $pglab::monitoringp


    postgresql::server::role { $mu:
        password_hash => postgresql_password($mu, $mp),
    }

    postgresql::server::pg_hba_rule { 'ACL for monitoring':
      type        => 'local',
      database    => 'all',
      user        => $mu,
      auth_method => 'md5',
      order       => '001'
    }

    # Create some databases from a hiera hash
    #create_resources(pglab::setdb, $pglab::databases)
    $pglab::databases.each |$d, $p| { pglab::setdb { $d: * => $p } }

    # Replication user
    $ru = $pglab::replicationu
    $rp = $pglab::replicationp

    # Replication role
    postgresql::server::role { $ru:
        password_hash => postgresql_password($ru, $rp),
        replication   => true,
    }

    postgresql::server::pg_hba_rule { 'ACL for replication':
      type        => 'host',
      database    => 'replication',
      address     => '0.0.0.0/0',
      user        => $ru,
      auth_method => 'md5',
      order       => '001'
    }

    postgresql::server::pg_hba_rule { 'ACL for local replication':
      type        => 'local',
      database    => 'replication',
      user        => $ru,
      auth_method => 'md5',
      order       => '001'
    }

    # Password file for automatic backup and replication
    file { '/var/lib/pgsql/.pgpass' :
        mode      => '0600',
        show_diff => false,
        content   => template('pglab/pgpass'),
        require   => Class['postgresql::server'],
    }

    # pgpool user
    $pu = $pglab::pgpoolu
    $pp = $pglab::pgpoolp

    # pgpool role
    postgresql::server::role { $pu:
        password_hash => postgresql_password($pu, $pp),
    }

    # pgpool ACL : address should be refined to allow only the
    # connections from the pgpool host(s)
    postgresql::server::pg_hba_rule { 'ACL for pgpool':
      type        => 'host',
      database    => 'all',
      address     => '0.0.0.0/0',
      user        => $pu,
      auth_method => 'md5',
      order       => '001'
    }

    # Required for sensu monitoring
    # rubygem-pg from EPEL is broken for me.
    package { 'rubygem-pg': ensure  => present, }

    # Some folders
    $archpath = "${pgbase}/${pglab::archivedir}"
    $bkppath  = "${pgbase}/${pglab::backupdir}"
    $sbypath  = "${pgbase}/${pglab::standbydir}"


    # Archive folder
    file { $archpath :
        ensure  => directory,
        mode    => '0750',
        require => [ Class['postgresql::server'], File[$pgbase] ],
    }

    # Backup folder
    file { $bkppath :
        ensure  => directory,
        mode    => '0750',
        require => [ Class['postgresql::server'], File[$pgbase] ],
    }

    # Hot standby folder (not used on the primary active server)
    file { $sbypath :
        ensure  => directory,
        mode    => '0700',
        require => [ Class['postgresql::server'], File[$pgbase] ],
    }

    # Configuration for archiving, hot backup and hot standby
    postgresql::server::config_entry {
        'wal_level'         : value   => 'hot_standby';
        'archive_mode'      : value   => 'on';
        'wal_keep_segments' : value   => '16';
        # Needed by pg_basebackup and the replication :
        'max_wal_senders'   : value   => '2';
        'log_filename'      : value   => 'postgresql-%Y-%m-%d_%H%M%S.log';
    }

    postgresql::server::config_entry { 'archive_command':
        value   => "cp %p ${archpath}/%f",
        require => File[ $archpath ],
    }

    # Shell profile
    file { 'psql.sh' :
        path    => '/etc/profile.d/psql.sh',
        content => template('pglab/psql.sh'),
        owner   => 'root',
        group   => 'root',
    }

    file { '/var/lib/pgsql/.bash_profile' :
        mode    => '0644',
        content => template('pglab/bash_profile'),
        require => Class['postgresql::server'],
    }

    if ($pglab::setfwrules == true) { include pglab::firewall }

}
