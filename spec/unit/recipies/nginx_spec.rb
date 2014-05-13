require File.expand_path('../../../spec_helper', __FILE__)

describe 'rails_stack::nginx' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:rails_stack][:apps] = {
        myapp_production: {}
      }
    end.converge(described_recipe)
  end

  it 'reloads nginx' do
    expect(chef_run).to reload_service('nginx')
  end

  it 'creates nginx cache directory for app' do
    expect(chef_run).to create_directory('/mnt/nginx_cache/myapp_production').
      with(user: 'www-data', group: 'www-data')
  end

  it 'logrotate' do
    # not sure how to get ChefSpec to execute the logrotate_app definition
    pending
    #expect(chef_run).to create_file('/etc/logrotate.d/nginx-myapp_production.conf')
  end
end
