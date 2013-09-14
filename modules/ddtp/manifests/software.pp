class ddtp::software {
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
