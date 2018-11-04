# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-image::swift_store' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      runner.converge(described_recipe)
    end
    include_context 'image-stubs'
    it do
      expect(chef_run).to upgrade_package('python-swift')
    end
  end
end
