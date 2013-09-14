class ddtp::database::server {
	package { 'postgresql': }

	service { 'postgresql':
		enable => true,
		require => Package['postgresql'],
	}
}

class ddtp::database {
	# Create ddtp user
	exec { "create ddtp user":
		command => '/usr/bin/createuser ddtp --no-createdb --no-createrole --no-superuser',
		user => postgres,
		require => Service['postgresql'],
		unless => "/usr/bin/psql -c \"SELECT 1 FROM pg_roles WHERE rolname='ddtp'\" -qAt | grep -q 1",
	}

	exec { "password ddtp user":
		command => "/usr/bin/psql -c \"ALTER USER ddtp PASSWORD '$postgres_password'\"",
		user => postgres,
		require => [Service['postgresql'], Exec["create ddtp user"]],
	}

	exec { "create ddtp db":
		command => '/usr/bin/createdb ddtp --owner=ddtp --encoding=UTF8',
		user => postgres,
		require => Exec['create ddtp user'],
		unless => "/usr/bin/psql -c \"SELECT 1 FROM pg_database WHERE datname='ddtp'\" -qAt | grep -q 1",
	}
}
