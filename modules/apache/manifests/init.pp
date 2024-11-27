class apache {
  exec { 'apt-update':
    command => '/usr/bin/apt-get update'
  }
  Exec["apt-update"] -> Package <| |>

  package { 'apache2':
    ensure => installed,
  }

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    require => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/vagrant.conf':
    content => template('apache/virtual-hosts.conf.erb'),
    require => File['/etc/apache2/sites-enabled/000-default.conf'],
  }

  file { "/etc/apache2/sites-enabled/vagrant.conf":
    ensure  => link,
    target  => "/etc/apache2/sites-available/vagrant.conf",
    require => File['/etc/apache2/sites-available/vagrant.conf'],
    notify  => Service['apache2'],
  }

  file { "${document_root}/index.html":
    ensure  => present,
    source => 'puppet:///modules/apache/index.html',
    require => File['/etc/apache2/sites-enabled/vagrant.conf'],
    notify  => Service['apache2'],
  }

  package { ['php', 'php-mysqli', 'php-curl', 'php-gd', 'php-xml', 'php-mbstring', 'php-zip', 'php-soap', 'libapache2-mod-php']:
    ensure  => installed,
    require => Package['apache2'],
  }

  service { 'apache2':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    subscribe  => Package['php'],
    restart    => '/usr/sbin/apachectl configtest && /usr/sbin/service apache2 restart',  
  }

  exec { 'check-php-version':
    command => 'php -v',
    unless  => 'test -f /usr/bin/php',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    notify  => Notify['PHP version'],
  }

  #Notificar la versión de PHP
  notify { 'PHP version':
    message => 'La versión de PHP se ha verificado.',
  }
}