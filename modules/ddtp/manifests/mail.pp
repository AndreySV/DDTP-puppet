# This class installs a mail server. If you already have one you don't need
# this class.  Just as long a /usr/sbin/sendmail interface is provided.
class ddtp::mail::server {
    package { 'exim4': }
}