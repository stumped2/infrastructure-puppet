#/etc/puppet/modules/sitemaps/manifests/jira.pp

class sitemaps::jira (
  $dbhost = '127.0.0.1',
  $dbport = '5432',
  $dbuser = 'jira',
  $dbname = 'jira',
  $dbpass = 'test',
  $script_dir = '/root',
  $jira_url = 'issues.apache.org',
  $docroot = '/var/www/issues-data',
) {

  file {
    'jira_sitemap_index.sh':
      ensure  => present,
      path    => "${script_dir}/jira_sitemap_index.sh",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/jira_index.sh.erb');
    'jira_generate_sitemap.sh':
      ensure  => present,
      path    => "${script_dir}/jira_generate_sitemap.sh",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/jira_generate_sitemap.sh.erb');
    '.pgpass':
      ensure  => present,
      path    => '/root/.pgpass',
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      content => template('sitemaps/pgpass.erb');
  }

  cron { 'jira sitemap generate':
    ensure  => present,
    command => "${script_dir}/jira_sitemap_index.sh > ${docroot}/sitemaps/sitemap_index.xml",
    minute  => 12,
    hour    => 6,
    user    => 'root',
  }


}
