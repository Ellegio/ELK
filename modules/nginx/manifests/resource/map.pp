# define: nginx::resource::map
#
# This definition creates a new mapping entry for NGINX
#
# Parameters:
#   [*ensure*]     - Enables or disables the specified location (present|absent)
#   [*default*]    - Sets the resulting value if the source values fails to
#                    match any of the variants.
#   [*string*]     - Source string or variable to provide mapping for
#   [*mappings*]   - Hash of map lookup keys and resultant values
#   [*hostnames*]  - Indicates that source values can be hostnames with a
#                    prefix or suffix mask.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  nginx::resource::map { 'backend_pool':
#    ensure    => present,
#    hostnames => true,
#    default   => 'ny-pool-1,
#    string    => '$http_host',
#    mappings  => {
#      '*.nyc.example.com' => 'ny-pool-1',
#      '*.sf.example.com'  => 'sf-pool-1',
#    }
#  }
#
# Sample Usage (preserving input of order of mappings):
#
#  nginx::resource::map { 'backend_pool':
#    ...
#    mappings  => [
#      { 'key' => '*.sf.example.com', 'value' => 'sf-pool-1' },
#      { 'key' => '*.nyc.example.com', 'value' => 'ny-pool-1' },
#    ]
#  }
#
# Sample Hiera usage:
#
#  nginx::string_mappings:
#    client_network:
#      ensure: present
#      hostnames: true
#      default: 'ny-pool-1'
#      string: $http_host
#      mappings:
#        '*.nyc.example.com': 'ny-pool-1'
#        '*.sf.example.com': 'sf-pool-1'
#
# Sample Hiera usage (preserving input of order of mappings):
#
#  nginx::string_mappings:
#    client_network:
#      ...
#      mappings:
#        - key: '*.sf.example.com'
#          value: 'sf-pool-1'
#        - key: '*.nyc.example.com'
#          value: 'ny-pool-1'


define nginx::resource::map (
  $string,
  $mappings,
  $default    = undef,
  $ensure     = 'present',
  $hostnames  = false
) {
  validate_string($string)
  validate_re($string, '^.{2,}$',
    "Invalid string value [${string}]. Expected a minimum of 2 characters.")
  if ! ( is_array($mappings) or is_hash($mappings) ) {
    fail("\$mappings must be a hash of the form { 'foo' => 'pool_b' } or array of hashes of form [{ 'key' => 'foo', 'value' => 'pool_b' }, ...]")
  }
  validate_bool($hostnames)
  validate_re($ensure, '^(present|absent)$',
    "Invalid ensure value '${ensure}'. Expected 'present' or 'absent'")
  if ($default != undef) { validate_string($default) }

  $root_group = $::nginx::root_group
  $conf_dir   = "${::nginx::conf_dir}/conf.d"

  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => 'file',
  }

  File {
    owner => 'root',
    group => $root_group,
    mode  => '0644',
  }

  file { "${::nginx::conf_dir}/conf.d/${name}-map.conf":
    ensure  => $ensure_real,
    content => template('nginx/conf.d/map.erb'),
    notify  => Class['::nginx::service'],
    require => File[$conf_dir],
  }
}
