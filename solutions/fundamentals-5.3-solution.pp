class users {
  user { 'fundamentals':
    ensure => present,
    gid    => 'staff',
    shell  => '/bin/zsh',
  }
  group { 'staff':
    ensure => present,
    gid    => 9999,
  }
}
