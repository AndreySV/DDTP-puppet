# This is a puppet manifest describing how to install the DDTP software.

# Webserver configuration
$enable_ssl = true
$server_name = 'ddtp.debian.org'
$server_admin = 'debian-l10n-devel@lists.alioth.debian.org'

$postgres_password = md5($macaddress)

# These are modules that do the installation of various servers. If you are
# integrating this into an existing system you probably need to modify or
# remove these.
include ddtp::webserver::server
include ddtp::database::server
include ddtp::mail::server

# These are the modules that do the configuration necessary for the DDTP
# itself.  These indirectly depend on the above packages so might need
# slight adjustment if you modify them.  These are the guts of the
# configuration.
include ddtp::software
include ddtp::webserver
include ddtp::database
include ddtp::software::mail

# This class are for monitoring for problems
include ddtp::monitoring::munin
