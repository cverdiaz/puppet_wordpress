class wordpress {

  # Instalar wget si no está presente
  package { 'wget':
    ensure => 'installed',
  }

  # Asegúrate de que el directorio /var/www/html/wordpress exista antes de descomprimir WordPress
  file { '/var/www/html/wordpress':
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,  # Aplica los permisos recursivamente a todo el contenido
    require => Package['wget'],  # Asegura que wget esté instalado antes de crear el directorio
  }

  # Descargar WordPress
  exec { 'download_wordpress':
    command => '/usr/bin/wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz',
    creates => '/tmp/latest.tar.gz',  # Solo descarga si no existe el archivo
    path    => ['/usr/bin', '/bin'],  # Se añade el path donde está wget
    require => Package['wget'],   # Asegura que wget esté instalado antes de ejecutar
  }

  # Descomprimir WordPress en el directorio adecuado
  exec { 'extract_wordpress':
    command => '/bin/tar -xvzf /tmp/latest.tar.gz -C /var/www/html/wordpress --strip-components=1',
    creates => '/var/www/html/wordpress/index.php',  # Verifica que los archivos de WordPress estén presentes
    require => [
      Exec['download_wordpress'],  # Asegura que el archivo se descargue antes de descomprimir
      File['/var/www/html/wordpress'],  # Asegura que el directorio exista antes de extraer
    ],
    path    => ['/bin', '/usr/bin'],
  }

  # Copiar el archivo de configuración de WordPress
  file { '/var/www/html/wordpress/wp-config.php':
    ensure  => file,
    source  => 'puppet:///modules/wordpress/wp-config.php',
    require => Exec['extract_wordpress'],  # Asegura que WordPress se haya extraído antes de copiar el archivo
  }

  # Instalar wp-cli (WordPress Command Line Interface)
  #package { 'wp-cli':
  #  ensure => 'installed',
  #}

  # Descargar e instalar wp-cli (WordPress CLI) manualmente
  exec { 'download_wpcli':
    command => '/usr/bin/wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp',
    creates => '/usr/local/bin/wp',  # Verifica si wp-cli ya está instalado
    require => Package['wget'],  # Asegura que wget esté instalado
  }

  # Hacer el archivo wp-cli ejecutable
  exec { 'make_wpcli_executable':
    command => '/bin/chmod +x /usr/local/bin/wp',
    require => Exec['download_wpcli'],
  }

  # Instalar WordPress usando wp-cli
  exec { 'install_wordpress':
    command => 'sudo -u www-data /usr/local/bin/wp core install --url="http://localhost:8080" --title="Mi Primer Blog" --admin_user="admin" --admin_password="Wp@12345" --admin_email="carlos.vera@umag.cl" --path="/var/www/html/wordpress"',
    #creates => '/var/www/html/wordpress/wp-config.php',
    path    => ['/usr/bin', '/usr/local/bin', '/bin'],
    unless  => 'sudo -u www-data /usr/local/bin/wp core is-installed --path="/var/www/html/wordpress"',
    user    => 'www-data',  #Ejecutar como usuario www-data
    require => [
      File['/var/www/html/wordpress/wp-config.php'],
      Exec['extract_wordpress'],
      Exec['make_wpcli_executable'],
    ],
  }

  # Crear un primer post usando wp-cli
  exec { 'create_first_post':
    command => '/usr/local/bin/wp post create --post_title="Bienvenidos a mi blog" --post_content="Este es el primer post de mi blog." --post_status=publish --path="/var/www/html/wordpress"',
    unless  => '/usr/local/bin/wp post list --path="/var/www/html/wordpress" | grep "Bienvenidos a mi blog"',
    path    => ['/usr/bin', '/bin', '/usr/local/bin'],
    require => Exec['install_wordpress'],
  }
}