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
}