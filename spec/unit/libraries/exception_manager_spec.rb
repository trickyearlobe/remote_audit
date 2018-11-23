require 'spec_helper'

describe RemoteAudit::ExceptionManager do
  it 'should catch exceptions' do
    lambda do
      described_class.execblock do
        raise 'Raised an exception. Lets see it it gets caught'
      end
    end.should_not raise_error
  end
end
