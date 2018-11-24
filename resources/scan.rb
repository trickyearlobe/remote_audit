require 'inspec'

property :profile_name, String, required: true
property :profile_user, String, required: true
property :node_name, String, required: true
property :target, String, required: true, sensitive: true

default_action :run

action :run do
  RemoteAudit::ExceptionManager.execblock do
    guid = RemoteAudit::GuidManager.get(new_resource.node_name)
    fq_profile_path = "/owners/#{new_resource.profile_user}/compliance/#{new_resource.profile_name}/tar"
    results = {}

    Chef::Log.debug "Starting scan of node #{new_resource.node_name} with guid #{guid}"
    Chef::Log.debug "Instantiating Inspec runner with target: '#{new_resource.target}'"
    runner = Inspec::Runner.new({'target' => new_resource.target, 'report' => true })

    rest = Chef::ServerAPI.new
    Chef::Log.debug "Fetching profile #{new_resource.profile_user}/#{new_resource.profile_name}"
    tmpfile = Tempfile.new(["#{new_resource.profile_name}-", 'tgz'])
    rest.streaming_request(fq_profile_path, {}, tmpfile) do |tempfile|
      Chef::Log.debug "Running profile in: '#{tempfile.path}'"
      runner.add_target(tempfile.path)
      runner.run
      results = runner.report
    end

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
    results[:environment] = "remote_scanner_#{node.name}"
    results[:report_uuid] = SecureRandom.uuid

    report_size = results.to_json.bytesize
    if report_size > 900*1024
      Chef::Log.warn "Compliance report size is #{(report_size / (1024 * 1024.0)).round(2)} MB."
    else
      Chef::Log.debug "Compliance report size is #{(report_size / (1024 * 1024.0)).round(2)} MB."
    end

    rest = Chef::ServerAPI.new("#{Chef::Config[:chef_server_url]}",Chef::Config)
    rest.post('data-collector', results)

    # Abuse converge_by to display stats in a nice way (and flag that an action occured if using "notifies")
    converge_by "Inspec summary for #{new_resource.node_name}: #{passed_controls} successful, #{failed_controls} failures, #{skipped_controls} skipped in #{results[:statistics][:duration]}s" do
    end
  end
end
