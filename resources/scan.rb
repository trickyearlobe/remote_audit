require 'inspec'

property :profiles, Array, required: true
property :node_name, String, required: true
property :target, String, required: false, sensitive: true
property :inputs, Hash, required: false, sensitive: true
property :waiverfile, Hash, required: false, sensitive: false
property :policy_name, String, default: node['policy_name'] || "not_set"
property :policy_group, String, default: node['policy_group'] || "not_set"
property :chef_tags, Array, default: ['remote_audit']
property :ipaddress, String, default: node[:ipaddress]
property :platform, Hash, default: {name:"TBA", release:"1.0"}
property :source_fqdn, String, default: "Scanner #{node['fqdn']}"
property :organization, String, default: "Remote Scanner"
property :environment, String, default: "remote_scanner_#{node.name}"

default_action :run

action :run do
  $stdout.puts "" # Make output more
  RemoteAudit::ExceptionManager.execblock do
    guid = RemoteAudit::GuidManager.get(new_resource.node_name)
    opts = { "report" => true }
    opts['target']  = new_resource.target if new_resource.target
    opts['inputs']  = new_resource.inputs if new_resource.inputs
    opts['waiverfile'] = Array(new_resource.waiverfile) if new_resource.waiverfile

    Chef::Log.debug "Starting scan of node #{new_resource.node_name} with guid #{guid}"
    runner = Inspec::Runner.new(opts)

    new_resource.profiles.each do |p|
      RemoteAudit::ExceptionManager.execblock do
        profile = RemoteAudit::ProfileManager.download_profile(p)
        runner.add_target(profile.path)
      end
    end

    runner.run
    results = runner.report

    passed_controls = results[:controls].select { |c| c[:status] == 'passed' }.size
    failed_controls = results[:controls].select { |c| c[:status] == 'failed' }.size
    skipped_controls = results[:controls].select { |c| c[:status] == 'skipped' }.size

    results[:profiles].select! { |p| p } # Remove nil profiles
    results[:type] = 'inspec_report'
    results.delete(:controls) # Ensure source controls are never stored or shipped
    results[:platform].delete :target # Ensure we dont report the target as it may contain passwords
    results[:node_name] = new_resource.node_name
    results[:end_time] = Time.now.utc.strftime('%FT%TZ')
    results[:node_uuid] = guid
    results[:environment] = new_resource.environment
    results[:report_uuid] = SecureRandom.uuid

    results[:platform] = new_resource.platform 
    results[:source_fqdn] = new_resource.source_fqdn
    results[:organization_name] = new_resource.organization
    results[:policy_group] = new_resource.policy_group
    results[:policy_name] = new_resource.policy_name
    results[:chef_tags] = new_resource.chef_tags
    results[:ipaddress] = new_resource.ipaddress
    results[:fqdn] = new_resource.node_name

    report_size = results.to_json.bytesize
    if report_size > 900 * 1024
      Chef::Log.warn "Compliance report size is #{(report_size / (1024 * 1024.0)).round(2)} MB"
    end

    rest = Chef::ServerAPI.new
    rest.post('data-collector', results)

    # Abuse converge_by to display converge stats
    converge_by "Inspec summary for #{new_resource.node_name}:"\
      " #{passed_controls} successful,"\
      " #{failed_controls} failures,"\
      " #{skipped_controls} skipped"\
      " in #{results[:statistics][:duration].round(2)}s"\
      " size #{(report_size / (1024 * 1024.0)).round(2)}mB" do
    end
  end
end
