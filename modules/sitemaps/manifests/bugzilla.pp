#/etc/puppet/modules/sitemap/manifests/bugzilla.pp

class sitemaps::bugzilla (
  $dbuser = 'bugsreadonly',
  $dbpass= 'test',
  $dbhost = '127.0.0.1',
  $bz_url = 'bz.apache.org',
  $docroot = '/var/www/bz-data',
  $script_dir = '/root',
) {

  file {
    'bugzilla_sitemap_index.sh':
      ensure  => present,
      path    => "${script_dir}/bugzilla_sitemap_index.sh",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/bugzilla_index.sh.erb');
    'bugzilla_generate_sitemap.sh':
      ensure  => present,
      path    => "${script_dir}/bugzilla_generate_sitemap.sh",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/bugzilla_generate_sitemap.sh.erb');
    '.my.cnf':
      ensure  => present,
      path    => '/root/.my.cnf',
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/my.cnf.erb');
  }->

  cron { 'bugzilla sitemap generate':
    ensure  => present,
    command => "${script_dir}/bugzilla_sitemap_index.sh > ${docroot}/sitemap/sitemap_index.xml",
    minute  => 12,
    hour    => 6,
    user    => 'root',
  }

}
