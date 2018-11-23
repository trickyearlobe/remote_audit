require 'spec_helper'

describe RemoteAudit::GuidManager do
  it 'should raise exceptions for instance methods' do
    lambda { described_class.new }.should raise_error('RemoteAudit::GuidManager doesnt need to be instantiated')
    lambda { described_class.new.get }.should raise_error('RemoteAudit::GuidManager doesnt need to be instantiated')
  end
  it '.get should reject invalid node names' do
    lambda { described_class.get('n ode1') }.should raise_error('Invalid Node Name')
    lambda { described_class.get('node1!') }.should raise_error('Invalid Node Name')
    lambda { described_class.get('node1!') }.should raise_error('Invalid Node Name')
  end
  it '.get should accept valid node names' do
    lambda { described_class.get('node1') }.should_not raise_error
    lambda { described_class.get('node_1.test-domain.com') }.should_not raise_error
    lambda { described_class.get('Node_1.test-domain.com') }.should_not raise_error
  end
  it '.get should return a valid GUID for a node' do
    described_class.get('node1').should match(/^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$/i)
  end
  it '.get should return unique GUIDs for different nodes' do
    described_class.get('node1').should_not == described_class.get('node2')
  end
  it '.get should remember the GUID it assigned to a node' do
    described_class.get('node1').should == described_class.get('node1')
  end
end
