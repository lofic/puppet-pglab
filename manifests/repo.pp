# PGDG yum repo

class pglab::repo {

    $pgver = $pglab::pgversion

    $pgyumsrv = 'download.postgresql.org'
    $orm = $facts['os']['release']['major']

    yumrepo { "PostgreSQL ${pgver}":
        baseurl  =>
          "https://${pgyumsrv}/pub/repos/yum/10/redhat/rhel-${orm}-x86_64",
        name     => "PostgreSQL-${pgver}",
        descr    => "PostgreSQL ${pgver}",
        enabled  => true,
        gpgcheck => true,
        gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
        require  => File['RPM-GPG-KEY-PGDG']
    }

    file { 'RPM-GPG-KEY-PGDG':
        path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
        source => 'puppet:///modules/pglab/RPM-GPG-KEY-PGDG',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }


}
