# rails_stack_nginx resource

actions :setup
default_action :setup

attribute :app_name, kind_of: String, name_attribute: true
attribute :cache_store_dir, kind_of: String
