class RemoteAuditException < RuntimeError
end

class RemoteAudit
  # A class that prrovides nested exception handling
  class ExceptionManager
    def self.execblock
      yield
    rescue StandardError => e
      log_exception(e)
    end

    def self.log_exception(exception, indent = 0)
      Chef::Log.warn "#{'  ' * indent}#{exception} at #{exception.backtrace[0]}" # unless const_defined? 'ChefSpec'
      log_exception(exception.cause, indent + 1) if exception.respond_to?(:cause) && exception.cause
    end
  end
end
