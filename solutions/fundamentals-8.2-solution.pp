class apache {
  File {
    owner => 'apache',
    group => 'apache',
    mode => '0644',
  }
  package { 'httpd':
    ensure => present,
  }
  file { '/var/www':
    ensure => directory,
  }
  file { '/var/www/html':
    ensure => directory,
  }
  file { '/var/www/html/index.html':
    ensure => file,
    source => 'puppet:///modules/apache/index.html',
  }
  file { '/etc/httpd/conf/httpd.conf':
    ensure => file,
    source => 'puppet:///modules/apache/httpd.conf',
    require => Package['httpd'],
  }
  service { 'httpd':
    ensure => running,
    enable => true,
    require => File['/etc/httpd/conf/httpd.conf'],
  }
}
