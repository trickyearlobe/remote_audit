#
# Cookbook:: remote_audit
# Recipe:: test_custom_resource
#
# Copyright:: 2018, The Authors, All Rights Reserved.

remote_audit_scan 'ncc-1701-cis-centos7' do
  profile_name 'sample'
  profile_user 'admin'
  node_name 'ncc-1701'
  target 'ssh://root:vagrant@127.0.0.1'
end
