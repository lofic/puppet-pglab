# Firewall rules for the PostgreSQL server

class pglab::firewall {

    include firewalld

    firewalld_port { '220 Postgres' :
          ensure   => present,
          protocol => 'tcp',
          port     => '5432',
          zone     => 'public'
    }

    firewalld_port { '221 Postgres' :
          ensure   => present,
          protocol => 'tcp',
          port     => '6543',
          zone     => 'public'
    }

}
