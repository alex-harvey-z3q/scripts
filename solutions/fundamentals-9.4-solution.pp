class apache {
  case $::osfamily {
    'RedHat': {
      $httpd_user  = 'apache'
      $httpd_group = 'apache'
      $httpd_pkg   = 'httpd'
      $httpd_svc   = 'httpd'
      $httpd_conf  = 'httpd.conf'
      $httpd_confdir = '/etc/httpd/conf'
      $httpd_docroot = '/var/www/html'
    }
    'Debian': {
      $httpd_user  = 'www-data'
      $httpd_group = 'www-data'
      $httpd_pkg   = 'apache2'
      $httpd_svc   = 'apache2'
      $httpd_conf  = 'apache2.conf'
      $httpd_confdir = '/etc/apache2'
      $httpd_docroot = '/var/www'
    }
    default: {
      fail("This module is not supported on ${::osfamily}")
    }
  }
  File {
    owner => $httpd_user,
    group => $httpd_group,
    mode  => '0644',
  }
  package { $httpd_pkg:
    ensure => present,
  }
  # NOTE Apache on both RedHat and Debian creates
  # the /var/www directory.  Therefore having Puppet only
  # manage $httpd_docroot will work on both platforms.
  file { $httpd_docroot:
    ensure => directory,
  }
  file { "${httpd_docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/apache/index.html',
  }
  file { "$httpd_confdir/$httpd_conf":
    ensure => file,
    source => 'puppet:///modules/apache/httpd.conf',
    require => Package[$httpd_pkg],
  }
  service { $httpd_svc:
    ensure => running,
    enable => true,
    require => File["$httpd_confdir/$httpd_conf"],
  }
}
