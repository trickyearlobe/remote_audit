require 'securerandom'
require 'json'

class RemoteAudit
  # A class that remembers GUIDs that are assigned to nodes
  class GuidManager
    class << self
      def get(nodename)
        raise 'Invalid Node Name' unless nodename =~ /^[a-z0-9\-_.]+$/i
        unless @guids[nodename]
          @guids[nodename] = SecureRandom.uuid
          serialize_guids
        end
        @guids[nodename]
      end

      # Save the whales... er... I mean GUIDs
      def serialize_guids
        # Unless were doing unit testing in which case, dont write files
        ::File.write(@guid_file, JSON.pretty_generate(@guids)) unless const_defined? 'ChefSpec'
      end
    end

    # Load or create the GUID file
    @guid_file = ::File.join(Chef::Config[:file_cache_path], 'remote_audit_uuids.json')
    if ::File.exist?(@guid_file)
      @guids = JSON.parse(::File.read(@guid_file))
    else
      @guids = {}
      serialize_guids
    end

    def initialize
      raise 'RemoteAudit::GuidManager doesnt need to be instantiated'
    end

    def get
      raise 'RemoteAudit::GuidManager should be called as a class method, not an instance method'
    end
  end
end
