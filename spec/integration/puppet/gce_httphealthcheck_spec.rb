require 'spec_helper'
require 'helpers/integration_spec_helper'

describe "gce_httphealthcheck" do
  it_behaves_like "a resource that can be created and destroyed" do
    let(:type) { 'gce_httphealthcheck' }
    let(:provider) { Puppet::Type::Gce_httphealthcheck::ProviderGcloud.new }
    let(:describe_args) { 'puppet-test-http-health-check' }
    let(:expected_properties) { {'name'               => 'puppet-test-http-health-check',
                                 'checkIntervalSec'   => 7,
                                 'timeoutSec'         => 7,
                                 'description'        => "Http-health-check for testing the puppetlabs-gce_compute module",
                                 'healthyThreshold'   => 7,
                                 'host'               => 'testhost',
                                 'port'               => 666,
                                 'requestPath'        => '/test/path',
                                 'unhealthyThreshold' => 7} }
  end
end
