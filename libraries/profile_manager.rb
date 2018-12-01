class RemoteAudit
  # A class that downloads and caches profiles (in a single run)
  class ProfileManager
    # Remember where we downloaded the profiles to
    @profile_paths = {}
    class << self
      # Call this method to download a profile (with cacheing)
      def download_profile(options = {})
        raise 'Expected :source' unless options[:source]
        case options[:source]
        when 'chef'
          download_profile_chef(options)
        else
          raise "Unrecognised profile source #{options[:source]}"
        end
      end

      # Download via Chef server (usually from Automate)
      def download_profile_chef(options = {})
        raise 'Expected :owner' unless options[:owner]
        raise 'Expected :profile' unless options[:profile]
        uri_path = build_uri_path(options)
        @profile_paths[options[:profile]] ||= begin
          tf = Tempfile.new([options[:profile] + '-', '.tgz'])
          tf.binmode
          tf.write ::File.read(Chef::ServerAPI.new.streaming_request(uri_path, {}))
          tf.close
          tf
        end
      end

      # Non source specific path builder
      def build_uri_path(options)
        case options[:source]
        when 'chef'
          build_uri_path_chef(options)
        else
          raise "Unrecognised profile source #{options[:source]}"
        end
      end

      # Chef specific path builder (for profiles in Automate)
      def build_uri_path_chef(options = {})
        raise 'Expected :owner'   unless options[:owner]
        raise 'Expected :profile' unless options[:profile]
        if options[:version]
          "/owners/#{options[:owner]}/compliance/#{options[:profile]}/version/#{options[:version]}/tar"
        else
          "/owners/#{options[:owner]}/compliance/#{options[:profile]}/tar"
        end
      end
    end
  end
end
