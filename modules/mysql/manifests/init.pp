class mysql {

  $root_password = 'dan007'  # Aquí define la contraseña para root

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

  exec { 'set_mysql_root_password':
    command => "/usr/bin/mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${root_password}'; FLUSH PRIVILEGES;\"",
    path    => ['/bin', '/usr/bin'],
    unless  => "/usr/bin/mysql -u root -p ${root_password} -e 'SHOW DATABASES;'",
    require => Service['mysql'],
  }

  # exec { 'secure_mysql_installation':
  #   command => '/usr/bin/mysql_secure_installation --use-default',
  #   path    => ['/bin', '/usr/bin'],
  #   onlyif  => 'test -f /usr/bin/mysql',
  #   require => Service['mysql'],
  # }

  exec { 'restart_mysql':
    command => '/bin/systemctl restart mysql',
    path    => ['/bin', '/usr/bin'],
    require => Exec['set_mysql_root_password'],
  }

  # Incluir configuración para WordPress
  include mysql::wordpress_config
}
