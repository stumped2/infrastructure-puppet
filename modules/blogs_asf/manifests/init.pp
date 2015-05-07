#/etc/puppet/modules/blogs_asf/manifests/init.pp

class blogs_asf (
  $r_uid             = 8998,
  $r_gid             = 8998,
  $r_group_present   = 'present',
  $r_groupname       = 'roblogs',
  $groups            = [],
  $service_ensure    = 'stopped',
  $service_name      = 'roller',
  $shell             = '/bin/bash',
  $r_user_present    = 'present',
  $r_username        = 'roblogs',
  $required_packages = ['tomcat7'],
){

# install required packages:
  package {
    $required_packages:
      ensure => 'present',
  }

# roller specific
  $roller_version           = '5.1'
  $roller_revision_number   = '2'
  $roller_release           = "${roller_version}.${roller_revision_number}"
  $mysql_connector_version  = '5.1.11'
  $mysql_connector          = "mysql-connector-java-${mysql_connector_version}.jar" # lint:ignore:80chars
  $mysql_connector_dest_dir = '/x1/roller/current/roller/WEB-INF/lib'
  $roller_build             = "roller-release-${roller_release}"
  $r_tarball                = "${roller_build}-standard.tar.gz"
  $download_dir             = '/tmp'
  $downloaded_tarball       = "${download_dir}/${r_tarball}"
  $download_url             = "https://dist.apache.org/repos/dist/release/roller/roller-${roller_version}/v${roller_release}/${r_tarball}"
  $parent_dir               = '/x1/roller'
  $install_dir              = "${parent_dir}/${roller_build}"
  $data_dir                 = '/x1/roller_data'
  $server_port              = '8008'
  $connector_port           = '8080'
  $context_path             = '/'
  $current_dir              = "${parent_dir}/current"
  $docroot                  = '/var/www'

  user {
    $r_username:
      ensure     => $r_user_present,
      name       => $r_username,
      home       => "/home/${r_username}",
      shell      => $shell,
      uid        => $r_uid,
      gid        => $r_groupname,
      groups     => $groups,
      managehome => true,
      require    => Group[$r_groupname],
  }

  group {
    $r_groupname:
      ensure => $r_group_present,
      name   => $r_groupname,
      gid    => $r_gid,
  }

# download roller
  exec {
    'download-roller':
      command => "/usr/bin/wget -O ${downloaded_tarball} ${download_url}",
      creates => $downloaded_tarball,
      timeout => 1200,
  }

  file { $downloaded_tarball:
    ensure  => file,
    require => Exec['download-roller'],
  }

# extract the download and move it
  exec {
    'extract-roller':
      command => "/bin/tar -xvzf ${r_tarball} && mv ${roller_build} ${parent_dir}", # lint:ignore:80chars
      cwd     => $download_dir,
      user    => 'root',
      creates => "${install_dir}/NOTICE.txt",
      timeout => 1200,
      require => [File[$downloaded_tarball],File[$parent_dir]],
  }

  exec {
    'chown-roller-dirs':
      command => "/bin/chown -R ${r_username}:${r_username} ${install_dir}",
      timeout => 1200,
      require => [User[$r_username],Group[$r_username]],
  }

  apache::vhost {
    'blogs-vm-80':
      vhost_name     => '*',
      priority       => '12',
      servername     => 'blogs-vm.apache.org',
      port           => '80',
      ssl            => false,
      docroot        => $docroot,
      error_log_file => 'blogs_error.log',
      serveraliases  => [
        'blogs-test.apache.org',
      ],
      #custom_fragment => 'RedirectMatch permanent ^/(.*)$ https://blogs-test.apache.org/$1'
  }

  file {
    $parent_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    $data_dir:
      ensure => directory,
      owner  => $r_username,
      group  => $r_groupname,
      mode   => '0775';

  }
}
