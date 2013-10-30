Exec { 
  path => [ "/usr/local/bin", "/usr/bin/", "/bin/", "/sbin/", "/usr/sbin/"  ]
}

exec { "update_apt":
    command => "apt-get update",
}

class { 'apt':
  always_apt_update => true
}

class python {
    package { [
        "build-essential",
        "python",
        "python-dev",
        "python-setuptools",
        ]:
        ensure => latest,
        require => Exec['update_apt'];
    }
    exec { "easy_install pip":
        unless => "which pip",
        require => Package['python-setuptools']
    }
    package { "virtualenv":
      ensure => latest,
      provider => pip,
      require => Exec['easy_install pip']
    }
}

class {'python': }

package { [
	"libpq-dev",
  "supervisor",
  "nginx",
  ]:
  ensure => latest,
  require => [Exec['update_apt'], Class['python']];
}

class { 'postgresql::server': 
	require => Exec['update_apt'];
}

postgresql::server::db { "sentry":
  user     => "sentry",
  password => "sentry",
  require  => Class['postgresql::server']
}

file { "/etc/nginx/sites-enabled/default":
  ensure => absent,
  subscribe => Package['nginx'],
}

file { "nginx-sentry.conf":
  name => "/etc/nginx/sites-available/sentry.conf",
  ensure => present,
  source => "/vagrant/conf/nginx/sentry.conf",
  require => Package['nginx'],
}

file { "/etc/nginx/sites-enabled/sentry.conf":
  ensure => symlink,
  target => "/etc/nginx/sites-available/sentry.conf",
  require => [
    Package['nginx'],
    File['nginx-sentry.conf']
  ]
}

file { "/var/sentry/":
    ensure => "directory",
}

file { "supervisor-sentry.conf":
    name => "/etc/supervisor/conf.d/sentry.conf",
    ensure => present,
    source => "/vagrant/conf/supervisord/sentry.conf",
    subscribe => [
        File['/var/sentry/'],
        Package['supervisor']
    ]
}

exec { 'create_virtualenv_install_sentry':
  command => 'virtualenv --no-site-packages ve && . ve/bin/activate && pip install sentry[postgres]',
  cwd => '/var/sentry',
  unless => 'test -d /var/sentry/ve',
  require => [
    Class['python'],
    Package['libpq-dev'],
    File['/var/sentry/']
  ]
}

file { "sentry.conf":
  name => "/var/sentry/sentry_conf.py",
  ensure => present,
  source => "/vagrant/conf/sentry/sentry_conf.py",
  require => Exec['create_virtualenv_install_sentry'],
}
