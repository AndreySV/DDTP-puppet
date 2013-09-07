# This is a puppet manifest describing how to install the DDTP software.

# Webserver configuration
$enable_ssl = 0
$server_name = 'ddtp.debian.net'
$server_admin = 'debian-l10n-devel@lists.alioth.debian.org'

include ddtp::webserver
