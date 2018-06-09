# Set a working lab for PostgreSQL.
# Needs the module puppetlabs/postgresql.
# You should override the passwords with hiera.

class pglab (
    String $pgversion,
    String $monitoringp,
    String $monitoringu    = 'monitor',
    String $monitoringip   = '127.0.0.1',
    String $monitoringport = '5432',

    String $replicationp,
    String $replicationu   = 'replication',

    String $pgpoolp,
    String $pgpoolu        = 'pgpool',

    String $pgbase         = '/pg',
    String $archivedir     = 'archives',
    String $backupdir      = 'backup',
    String $standbydir     = 'standby',

    Boolean $setfwrules    = true,

    Hash $databases        = {},

    ) {

    include pglab::server
}

