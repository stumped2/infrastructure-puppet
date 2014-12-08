class dhcp_asf (
  $pxeserver,
  $pool_network,
  $pool_name,
  $pool_range,
  $pool_gateway,
  $network,
  $interfaces,
)
{

  validate_string($pxeserver)
  validate_string($pool_name)
  validate_string($pool_network)
  validate_string($pool_range)
  validate_string($pool_gateway)
  validate_hash($network)
  validate_array($interfaces)

  $network_hash = hiera_hash($network)
  validate_hash($network_hash)

  class { 'dhcp':
    interfaces  => $interfaces,
    pxeserver   => $pxeserver,
    pxefilename => 'pxelinux.0',
  }

  dhcp::pool { $pool_name:
    network => $pool_network,
    mask    => '255.255.255.0',
    range   => $pool_range,
    gateway => $pool_gateway,
  }

  create_resources(dhcp::host, $network_hash)

}
