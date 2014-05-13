module RailsStack
  module Helpers
    def rails_apps
      node[:rails_stack].fetch(:apps, {}).map do |app_name, app|
        attrs = Chef::Mixin::DeepMerge.deep_merge(global_attributes, app.to_hash)
        mash = Mash.new(attrs)
        AppConf.new(node: node, full_name: app_name, app_node: mash)
      end
    end

    def global_attributes
      node.default[:rails_stack][:global]
    end

    def app_root_directory(resource)
      ::File.join(node[:rails_stack][:user_home], app_full_name(resource))
    end

    def app_full_name(resource)
      "#{resource.name}_#{resource.environment}"
    end
  end
end

Chef::Recipe.send(:include, RailsStack::Helpers)
Chef::Resource.send(:include, RailsStack::Helpers)
Chef::Provider.send(:include, RailsStack::Helpers)
