##/etc/puppet/modules/security_pvm_asf/manifests/init.pp

class security_pvm_asf (

  $required_packages             = ['maven' 'git' 'openjdk-8-jdk']

) {

# install required packages:
  package {
    $required_packages:
      ensure => 'present',
  }


  apt::source { 'wily':
    location => 'http://us.archive.ubuntu.com/ubuntu/',
    release  => 'wily',
    repos    => 'main',
  }

  apt::source { 'wily-updates':
    location => 'http://us.archive.ubuntu.com/ubuntu/',
    release  => 'wily-updates',
    repos    => 'main',
  }

  apt::pin { 'wily-maven':
    ensure   => present,
    priority => 1800,
    packages => 'maven',
    codename => 'wily',
    require  => Apt::Source['wily'],
    before   => Package['maven'],
  }

}
