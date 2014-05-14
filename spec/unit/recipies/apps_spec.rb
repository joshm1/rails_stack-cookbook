require File.expand_path('../../../spec_helper', __FILE__)

describe 'rails_stack::apps' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: [:rails_stack_app]) do |node|
      node.set[:rails_stack][:global] = default_global_attrs
      node.set[:rails_stack][:apps] = normal_apps_attrs
    end.converge(described_recipe)
  end

  let(:default_global_attrs) do
    {
      foo: 1,
      bar: { a: 0, b: 1 }
    }
  end

  let(:normal_apps_attrs) do
    {
      myapp_production: {
        foo: 5,
        bar: { a: 1 },
        baz: 4
      }
    }
  end

  let(:app_root_dir) { '/u/apps/myapp_production' }

  it 'automatically deep merges from global' do
    expect(chef_run).to be
    myapp_node = chef_run.node[:rails_stack][:apps][:myapp_production]
    expect(myapp_node[:foo]).to eq(5)
    expect(myapp_node[:bar]).to eq({ 'a' => 1, 'b' => 1})
    expect(myapp_node[:baz]).to eq(4)
  end

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
