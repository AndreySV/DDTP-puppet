class ddtp::software {
	include ddtp::software::setup
	include ddtp::software::config

	Class[ddtp::software::setup] -> Class[ddtp::software::config]
}

class ddtp::software::setup {
	# Create the ddtp user and directory
	file { '/srv':
		ensure => directory,
		owner => root,
		group => root,
		mode => 755,
	}

	file { "/srv/$server_name":
		ensure => directory,
		owner => ddtp,
		mode => 755,
	}

	user { 'ddtp':
		home => "/srv/$server_name",
		password => '*',
	}

	package { ['libdbd-pg-perl', 'libtext-diff-perl', 'libwww-perl', 'libmime-tools-perl']: }

	exec { "/usr/bin/git clone git://git.debian.org/git/debian-l10n/ddtp.git /srv/$server_name":
		user => ddtp,
		creates => "/srv/$server_name/.git",
		cwd => "/srv/$server_name",
		require => File["/srv/$server_name"],
	}
}

class ddtp::software::config {
	# pg_service file so everyone can login to database
	file { "/srv/$server_name/.pg_service.conf":
		content => template('ddtp/pg_service.conf'),
		owner => ddtp,
	}

	file { '/var/www/ddtp/ddt.cgi':
		ensure => "/srv/$server_name/ddt.cgi",
	}
}
