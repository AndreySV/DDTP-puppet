class ddtp::monitoring::nagios {
    package { 'nagios3-cgi': ensure => installed }
    package { 'nagios3': ensure => installed }

    service { 'nagios3':
        ensure => running,
        require => Package['nagios3'],
    }

    # Override config file primarily to remove access restrictions
    file { '/etc/apache2/conf-available/nagios3.conf':
        content => template("ddtp/apache2-nagios3.conf"),
        require => Package['nagios3','apache2'],
        notify => Service['apache2'],
    }

    file { '/etc/nagios3/htpasswd.users':
        content => template("ddtp/htpasswd.users"),
        require => Package['apache2'],
    }
}

class ddtp::monitoring::munin {
    package { 'munin': ensure => installed }

    # Override config file primarily to remove access restrictions
    file { '/etc/apache2/conf-available/munin':
        content => template("ddtp/apache2-munin.conf"),
        require => Package['munin','apache2'],
        notify => Service['apache2'],
    }
}

