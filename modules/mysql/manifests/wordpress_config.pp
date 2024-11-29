class mysql::wordpress_config {
  # Crear base de datos para WordPress
  exec { 'create_wordpress_db':
    command => '/usr/bin/mysql -uroot -e "CREATE DATABASE IF NOT EXISTS wordpress;"',
    path    => ['/bin', '/usr/bin'],
    unless  => '/usr/bin/mysql -uroot -e "SHOW DATABASES LIKE \'wordpress\';" | grep wordpress',
    require => Service['mysql'],
  }

  # Crear usuario para WordPress
  exec { 'create_wordpress_user':
    command => '/usr/bin/mysql -uroot -e "CREATE USER IF NOT EXISTS \'wp_user\'@\'localhost\' IDENTIFIED BY \'Wp@12345\';"',
    path    => ['/bin', '/usr/bin'],
    unless  => '/usr/bin/mysql -uroot -e "SELECT User FROM mysql.user WHERE User = \'wp_user\';" | grep wp_user',
    require => Exec['create_wordpress_db'],
  }

  # Otorgar permisos al usuario de WordPress
  exec { 'grant_permissions_wordpress':
    command => '/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON wordpress.* TO \'wp_user\'@\'localhost\'; FLUSH PRIVILEGES;"',
    path    => ['/bin', '/usr/bin'],
    require => Exec['create_wordpress_user'],
  }
}