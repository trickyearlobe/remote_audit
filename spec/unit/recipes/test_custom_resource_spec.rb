#
# Cookbook:: remote_audit
# Spec:: test_custom_resource
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'remote_audit::test_custom_resource' do
  context 'When all attributes are default, on CentOS 7.4.1708' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'runs an ncc-1701-cis-centos7 scan' do
      expect(chef_run).to run_remote_audit_scan('ncc-1701-cis-centos7')
    end
  end
end
