#
# Cookbook:: remote_audit
# Recipe:: test_custom_resource
#
# Copyright:: 2018, The Authors, All Rights Reserved.

remote_audit_scan 'ncc-1701 multiple profiles' do
  profiles [
    { source: 'chef', owner: 'admin', profile: 'sample' },
    { source: 'chef', owner: 'admin', profile: 'cis-centos7-level1'}
  ]
  node_name 'ncc-1701'
  target 'ssh://root:vagrant@127.0.0.1'
end

remote_audit_scan 'ncc-1702 multiple profiles' do
  profiles [
    { source: 'chef', owner: 'admin', profile: 'sample' },
    { source: 'chef', owner: 'admin', profile: 'cis-centos7-level1'}
  ]
  node_name 'ncc-1702'
  target 'ssh://root:vagrant@192.168.0.164'
end


remote_audit_scan 'Cisco Router 001' do
  profiles [{ source: 'chef', owner: 'admin', profile: 'cis-ciscoios12-level1' }]
  node_name 'cisco-001'
  target 'ssh://inspec:abc123@192.168.0.2'
end
