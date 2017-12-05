class ddtp::monitoring::munin {
    package { 'munin': ensure => installed }

    # Override config file primarily to remove access restrictions
    file { '/etc/apache2/conf-available/munin.conf':
        content => template("ddtp/apache2-munin.conf"),
        require => Package['munin','apache2'],
        notify => Service['apache2'],
    }
}

