class ddtp::software {
	include ddtp::software::setup
	include ddtp::software::config
	include ddtp::software::ddtp_dinstall

	Class[ddtp::software::setup] -> Class[ddtp::software::config]

	# And the final step after everything else, the cronjob
	cron { 'ddtp daily update':
		user => ddtp,
		minute => 6,
		hour => 1,
		command => "/usr/bin/nice /srv/$server_name/update.sh",
		require => Class[ddtp::software::config],
	}
}

class ddtp::software::setup {
	# Create the ddtp user and directory
	file { '/srv':
		ensure => directory,
		owner => root,
		group => root,
		mode => 'u=rwx,go=rx',
	}

	file { '/org':
		ensure => '/srv'
	}

	file { "/srv/$server_name":
		ensure => directory,
		owner => ddtp,
		mode => 'u=rwx,go=rx',
	}

	user { 'ddtp':
		home => "/srv/$server_name",
		password => '*',
	}

	package { ['libdbd-pg-perl', 'libtext-diff-perl', 'libwww-perl', 'libmime-tools-perl']: }
	package { 'bzip2': }
	package { 'gnuplot-nox': }

	exec { "/usr/bin/git clone git://anonscm.debian.org/debian-l10n/ddtp.git /srv/$server_name":
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

	# Create needed directories
	file { ["/srv/$server_name/log", "/srv/$server_name/gnuplot", "/srv/$server_name/pg_dump", "/srv/$server_name/www"]:
		ensure => directory,
		owner => ddtp,
		mode => 'u=rw,go=r',
	}

	file { ["/srv/$server_name/www/stats", "/srv/$server_name/www/source"]:
		ensure => directory,
		owner => ddtp,
		mode => 'u=rw,go=r',
	}

	# Link to web directory
	file { "/var/www/ddtp":
		ensure => link,
		target => "/srv/$server_name/www",
	}

	# Robots.txt file
	file { "/srv/$server_name/www/robots.txt":
		content => template('ddtp/robots.txt'),
		owner => ddtp,
		group => ddtp,
		mode => 'u=rw,go=r',
	}

	# DDTP CGI script
	file { "/srv/$server_name/www/ddt.cgi":
		ensure => "/srv/$server_name/ddt.cgi",
	}

	# DDTSS CGI script
	file { "/srv/$server_name/www/ddtss":
		ensure => directory,
		owner => ddtp,
	}

	file { "/srv/$server_name/www/ddtss/index.cgi":
		ensure => "/srv/$server_name/ddtss/ddtss-cgi",
	}

	file { "/srv/$server_name/www/ddtss/ddtss.css":
		ensure => "/srv/$server_name/ddtss/ddtss.css",
	}
}

class ddtp::software::ddtp_dinstall {
	file { '/srv/ddtp-dinstall':
		ensure => directory,
		owner => ddtp,
	}

	# Link must exist, though doesn't need to point anywhere
	file { '/srv/ddtp-dinstall/to-dak':
		ensure => link,
		target => 'x',
		replace => false,
	}

	# Special user for dak to login
	user { 'ddtp-dak':
		home => "/home/ddtp-dak",
		password => "*",
	}

	file { "/home/ddtp-dak":
		ensure => directory,
		owner => "ddtp-dak",
		mode => 'u=rwx,go=rx',
	}

	# This is the directory where the authorized_keys file must go to allow dak to login
	file { "/home/ddtp-dak/.ssh":
		ensure => directory,
		owner => "ddtp-dak",
		mode => 'u=rwx',
	}

	# Sample file for the correct options...
	file { "/home/ddtp-dak/.ssh/authorized_keys":
		owner => "ddtp-dak",
		mode => 'u=rw',
		replace => false,
		content => 'command="/usr/bin/rsync --server --sender -logDtpr . /srv/ddtp-dinstall/to-dak/.",from="ries.debian.org,128.148.34.103,franck.debian.org,128.148.34.3",no-agent-forwarding,no-port-forwarding,no-pty,no-X11-forwarding ssh-rsa AAA...',
	}
}

class ddtp::software::mail {
	file { "/srv/$server_name/.forward":
		owner => ddtp,
		mode => 'u=rw',
		content => template('ddtp/forward'),
	}

	file { ["/srv/$server_name/ddts/log", "/srv/$server_name/ddts/mail", "/srv/$server_name/ddts/tmp"]:
		ensure => directory,
		owner => ddtp,
		mode => 'u=rwx,go=rx',
	}
}
