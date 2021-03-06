# encoding: UTF-8
#
########################################################################
# Toggles - These can be overridden at the environment level
default['enable_monit'] = false # OS provides packages
########################################################################

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['compute']['custom_template_banner'] = '
# This file is automatically generated by Chef
# Any changes will be overwritten
'

# Set dbsync command timeout value
default['openstack']['compute']['dbsync_timeout'] = 3600

# Disallow non-encrypted connections
default['openstack']['compute']['service_role'] = 'admin'

# Used to set correct permissions for directories and files
default['openstack']['compute']['user'] = 'nova'
default['openstack']['compute']['group'] = 'nova'

# Logging stuff
default['openstack']['compute']['syslog']['facility'] = 'LOG_LOCAL1'
default['openstack']['compute']['syslog']['config_facility'] = 'local1'

# rootwrap.conf
default['openstack']['compute']['rootwrap']['filters_path'] = '/etc/nova/rootwrap.d,/usr/share/nova/rootwrap'
default['openstack']['compute']['rootwrap']['exec_dirs'] = '/sbin,/usr/sbin,/bin,/usr/bin'
default['openstack']['compute']['rootwrap']['use_syslog'] = 'False'
default['openstack']['compute']['rootwrap']['syslog_log_facility'] = 'syslog'
default['openstack']['compute']['rootwrap']['syslog_log_level'] = 'ERROR'

# SSL settings
%w(api placement metadata).each do |service|
  default['openstack']['compute'][service]['ssl']['enabled'] = false
  default['openstack']['compute'][service]['ssl']['certfile'] = ''
  default['openstack']['compute'][service]['ssl']['chainfile'] = ''
  default['openstack']['compute'][service]['ssl']['keyfile'] = ''
  default['openstack']['compute'][service]['ssl']['ca_certs_path'] = ''
  default['openstack']['compute'][service]['ssl']['cert_required'] = false
  default['openstack']['compute'][service]['ssl']['protocol'] = ''
  default['openstack']['compute'][service]['ssl']['ciphers'] = ''
end

# Platform specific settings
case node['platform_family']
when 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['compute']['platform'] = {
    'api_os_compute_packages' => ['openstack-nova-api'],
    'api_os_compute_service' => 'openstack-nova-api',
    'api_placement_packages' => ['openstack-nova-placement-api'],
    'api_placement_service' => 'openstack-nova-placement-api',
    'memcache_python_packages' => ['python-memcached'],
    'compute_api_metadata_packages' => ['openstack-nova-api'],
    'compute_api_metadata_service' => 'openstack-nova-metadata-api',
    'compute_compute_packages' => ['openstack-nova-compute'],
    'qemu_compute_packages' => [],
    'kvm_compute_packages' => [],
    'compute_compute_service' => 'openstack-nova-compute',
    'compute_scheduler_packages' => ['openstack-nova-scheduler'],
    'compute_scheduler_service' => 'openstack-nova-scheduler',
    'compute_conductor_packages' => ['openstack-nova-conductor'],
    'compute_conductor_service' => 'openstack-nova-conductor',
    'compute_vncproxy_packages' => ['openstack-nova-novncproxy'],
    'compute_vncproxy_service' => 'openstack-nova-novncproxy',
    'compute_vncproxy_consoleauth_packages' => ['openstack-nova-console'],
    'compute_vncproxy_consoleauth_service' => 'openstack-nova-consoleauth',
    'compute_serialproxy_packages' => ['openstack-nova-serialproxy'],
    'compute_serialproxy_service' => 'openstack-nova-serialproxy',
    'libvirt_packages' => ['libvirt', 'device-mapper', 'python-libguestfs'],
    'libvirt_service' => 'libvirtd',
    'dbus_service' => 'messagebus',
    'compute_cert_packages' => ['openstack-nova-cert'],
    'compute_cert_service' => 'openstack-nova-cert',
    'mysql_service' => 'mysqld',
    'common_packages' => ['openstack-nova-common'],
    'iscsi_helper' => 'ietadm',
    'volume_packages' => ['sysfsutils', 'sg3_utils', 'device-mapper-multipath'],
    'package_overrides' => '',
  }
when 'debian'
  default['openstack']['compute']['platform'] = {
    'api_os_compute_packages' => ['nova-api'],
    'api_os_compute_service' => 'nova-api',
    'api_placement_packages' => ['nova-placement-api'],
    'api_placement_service' => 'nova-placement-api',
    'memcache_python_packages' => ['python-memcache'],
    'compute_api_metadata_packages' => ['nova-api-metadata'],
    'compute_api_metadata_service' => 'nova-api-metadata',
    'compute_compute_packages' => ['nova-compute'],
    'qemu_compute_packages' => ['nova-compute-qemu'],
    'kvm_compute_packages' => ['nova-compute-kvm'],
    'compute_compute_service' => 'nova-compute',
    'compute_scheduler_packages' => ['nova-scheduler'],
    'compute_scheduler_service' => 'nova-scheduler',
    'compute_conductor_packages' => ['nova-conductor'],
    'compute_conductor_service' => 'nova-conductor',
    # Websockify is needed due to https://bugs.launchpad.net/ubuntu/+source/nova/+bug/1076442
    'compute_vncproxy_packages' => ['novnc', 'websockify', 'nova-novncproxy'],
    'compute_vncproxy_service' => 'nova-novncproxy',
    'compute_vncproxy_consoleauth_packages' => ['nova-consoleauth'],
    'compute_vncproxy_consoleauth_service' => 'nova-consoleauth',
    'compute_serialproxy_packages' => ['nova-serialproxy'],
    'compute_serialproxy_service' => 'nova-serialproxy',
    'libvirt_packages' => ['libvirt-bin', 'python-guestfs'],
    'libvirt_service' => 'libvirt-bin',
    'dbus_service' => 'dbus',
    'compute_cert_packages' => ['nova-cert'],
    'compute_cert_service' => 'nova-cert',
    'mysql_service' => 'mysql',
    'common_packages' => ['nova-common'],
    'iscsi_helper' => 'tgtadm',
    'volume_packages' => ['sysfsutils', 'sg3-utils', 'multipath-tools'],
    'package_overrides' => '',
  }
end

# Array of options for `api-paste.ini` (e.g. ['option1=value1', ...])
default['openstack']['compute']['misc_paste'] = nil

# ****************** OpenStack Compute Endpoints ******************************

# The OpenStack Compute (Nova) XVPvnc endpoint
%w(
  compute-xvpvnc compute-novnc
  compute-metadata-api
  compute-vnc compute-api
).each do |service|
  default['openstack']['bind_service']['all'][service]['host'] = '127.0.0.1'
  %w(public internal admin).each do |type|
    default['openstack']['endpoints'][type][service]['host'] = '127.0.0.1'
    default['openstack']['endpoints'][type][service]['scheme'] = 'http'
  end
end
%w(public internal admin).each do |type|
  default['openstack']['endpoints'][type]['compute-xvpvnc']['port'] = '6081'
  default['openstack']['endpoints'][type]['compute-xvpvnc']['path'] = '/console'
  # The OpenStack Compute (Nova) Native API endpoint
  default['openstack']['endpoints'][type]['compute-api']['port'] = '8774'
  default['openstack']['endpoints'][type]['compute-api']['path'] = '/v2.1/%(tenant_id)s'
  # The OpenStack Compute (Nova) novnc endpoint
  default['openstack']['endpoints'][type]['compute-novnc']['port'] = '6080'
  default['openstack']['endpoints'][type]['compute-novnc']['path'] = '/vnc_auto.html'
  # The OpenStack Compute (Nova) metadata API endpoint
  default['openstack']['endpoints'][type]['compute-metadata-api']['port'] = '8775'
  default['openstack']['endpoints'][type]['compute-metadata-api']['path'] = ''
  # The OpenStack Compute (Nova) serial proxy endpoint
  default['openstack']['endpoints'][type]['compute-serial-proxy']['scheme'] = 'ws'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['port'] = '6083'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['path'] = '/'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['host'] = '127.0.0.1'
  # The OpenStack Compute (Nova) Placement API endpoint
  default['openstack']['endpoints'][type]['placement-api']['port'] = '8778'
  default['openstack']['endpoints'][type]['placement-api']['path'] = ''
  default['openstack']['endpoints'][type]['placement-api']['host'] = '127.0.0.1'
end
default['openstack']['bind_service']['all']['compute-serial-proxy']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-vnc-proxy']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-serial-console']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-xvpvnc']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-vnc']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-serial-proxy']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-novnc']['port'] = '6080'
default['openstack']['bind_service']['all']['compute-metadata-api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-metadata-api']['port'] = '8775'
default['openstack']['bind_service']['all']['compute-api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-api']['port'] = '8774'
default['openstack']['bind_service']['all']['placement-api']['port'] = '8778'
default['openstack']['bind_service']['all']['placement-api']['host'] = '127.0.0.1'
