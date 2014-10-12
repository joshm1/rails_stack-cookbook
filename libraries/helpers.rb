module RailsStack
  module Helpers
    def enable_logentries?
      !!node[:logentries]
    end

    def rails_apps
      node[:rails_stack].fetch(:apps, {}).map do |app_name, app|
        merged_node = merge_app_with_global(app_name)
        AppConf.new(node: node, full_name: app_name, app_node: merged_node)
      end
    end

    def merge_app_with_global(app_name)
      node.default[:rails_stack][:apps][app_name] = global_attributes
      node[:rails_stack][:apps][app_name]
    end

    def global_attributes
      node[:rails_stack][:global]
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
