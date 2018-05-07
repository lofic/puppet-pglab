Facter.add( 'haspg' ) { setcode { File.directory?('/var/lib/pgsql') } }
