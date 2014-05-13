require File.expand_path('../../../spec_helper', __FILE__)

describe 'rails_stack::apps' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: [:rails_stack_app]) do |node|
      node.set[:rails_stack][:apps] = {
        myapp_production: {}
      }
    end.converge(described_recipe)
  end

  let(:app_root_dir) { '/u/apps/myapp_production' }

  describe 'directories created' do
    it do
      expect(chef_run).to create_directory(app_root_dir).
        with(owner: 'apps', group: 'apps')
    end
    it do
      expect(chef_run).to create_directory("#{app_root_dir}/shared/config").
        with(owner: 'apps', group: 'apps')
    end
  end
end
