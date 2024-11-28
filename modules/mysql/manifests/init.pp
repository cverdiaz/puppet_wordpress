class mysql {

  # Asegurarse de que el sistema esté actualizado
  exec { 'update_package_list':
    command => '/usr/bin/apt-get update -y',
    path    => ['/bin', '/usr/bin'],
    before  => Package['mysql-server'],
  }

  # Instalar el servidor MySQL desde el repositorio oficial de Ubuntu
  package { 'mysql-server':
    ensure => installed,
  }

  # Asegurar que el servicio de MySQL esté habilitado y en ejecución
  service { 'mysql':
    ensure     => running,
    enable     => true,
    require    => Package['mysql-server'],
  }

  # Configuración adicional (opcional)
  exec { 'secure_mysql_installation':
    command => '/usr/bin/mysql_secure_installation --use-default',
    path    => ['/bin', '/usr/bin'],
    onlyif  => 'test -f /usr/bin/mysql',
    require => Service['mysql'],
  }
}