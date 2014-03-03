class website {

  ## configure apache
  include apache
  include apache::mod::php
  apache::vhost {'alex.puppetlabs.vm':
    port => 80,
    docroot => '/var/www/alex.puppetlabs.vm',
  }
  host { 'alex.puppetlabs.vm':
    ip => $::ipaddress,
  }

  ## configure MySQL
  include mysql::server
  class { 'mysql::bindings':
    php_enable => true,
  }

  ## configure wordpress
  class { 'wordpress':
    install_dir => '/var/www/alex.puppetlabs.vm',
    require => Class['apache'],
  }

}
