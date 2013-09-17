# This is a puppet manifest describing how to install the DDTP software.

# Webserver configuration
$enable_ssl = 0
$server_name = 'ddtp.debian.net'
$server_admin = 'debian-l10n-devel@lists.alioth.debian.org'

$postgres_password = md5($macaddress)

include ddtp::webserver
include ddtp::software
include ddtp::database::server
include ddtp::database
include ddtp::mail::server
include ddtp::software::mail
