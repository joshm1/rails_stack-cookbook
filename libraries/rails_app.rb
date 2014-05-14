module RailsStack
  class NestedConf
    attr_reader :app_conf, :conf

    def initialize(app_conf)
      @app_conf = app_conf
      @conf = app_conf.fetch(conf_key, {})
    end

    def node
      app_conf.node
    end

    def [](key)
      conf[key]
    end

    def fetch(*args, &block)
      conf.fetch(*args, &block)
    end

    def full_name
      app_conf.full_name
    end

    def conf_key
      raise NotImplementedError, "#{self.class.name} must implement #conf_key"
    end
  end

  class AppConf
    attr_reader :node, :app_node, :full_name

    def initialize(opts)
      @node = opts[:node]
      @full_name = opts[:full_name]
      @app_node = opts[:app_node]
    end

    def name
      @name ||= app_node[:name] || derived_name
    end

    def environment
      @environment ||= app_node[:environment] || derived_environment
    end

    def [](key)
      app_node[key]
    end

    def fetch(*args, &block)
      app_node.fetch(*args, &block)
    end

    def project_root_dir
      ::File.join(app_node[:user_home], full_name)
    end

    def current_dir
      ::File.join(project_root_dir, 'current')
    end

    def releases_dir
      ::File.join(project_root_dir, 'releases')
    end

    def shared_dir
      ::File.join(project_root_dir, 'shared')
    end

    def config_dir
      ::File.join(shared_dir, 'config')
    end

    def log_dir
      ::File.join(shared_dir, 'log')
    end

    def tmp_dir
      ::File.join(shared_dir, 'tmp')
    end

    def pids_dir
      ::File.join(shared_dir, 'pids')
    end

    def sockets_dir
      ::File.join(shared_dir, 'sockets')
    end

    def nginx
      @nginx ||= NginxConf.new(self)
    end

    def app_server
      @app_server ||=
        AppServers.by_name(app_node[:app_server][:provider]).new(self)
    end

    def resque
      @resque ||= ResqueConf.new(self)
    end

    protected

    def derived_name
      derived_name_and_environment.name
    end

    def derived_environment
      derived_name_and_environment.environment
    end

    def derived_name_and_environment
      full_name_parts = full_name.split('_')
      Struct.new(:name, :environment).new(
        full_name_parts[0..-2].join('_'),
        full_name_parts[-1])
    end

  end

  class NginxConf < NestedConf
    def conf_key
      :nginx
    end

    def server_names
      server_names = conf.fetch(:server_names, '_')
      server_names = server_names.join(' ') if server_names.respond_to?(:join)
      server_names
    end

    def log_dir
      node[:nginx][:log_dir]
    end

    def access_log_path
      conf.fetch(:access_log_path, default_access_log_path)
    end

    def error_log_path
      conf.fetch(:error_log_path, default_error_log_path)
    end

    def enabled_file
      "/etc/nginx/sites-enabled/#{full_name}"
    end

    def available_file
      "/etc/nginx/sites-available/#{full_name}"
    end

    protected

    def default_access_log_path
      ::File.join(log_dir, "#{full_name}.access.log")
    end

    def default_error_log_path
      ::File.join(log_dir, "#{full_name}.error.log")
    end
  end

  class ResqueConf < NestedConf
    def service_name
      "#{full_name}-resque"
    end

    def init_file
      "/etc/init.d/#{service_name}"
    end

    def config_file
      ::File.join(app_conf.config_dir, 'resque-pool.yml')
    end

    def init_log
      ::File.join(app_conf.log_dir, 'resque-pool.init.log')
    end

    def stderr_log
      ::File.join(app_conf.log_dir, 'resque-pool.stderr.log')
    end

    def stdout_log
      ::File.join(app_conf.log_dir, 'resque-pool.stdout.log')
    end

    def pid_file
      ::File.join(app_conf.pids_dir, 'resque-pool.pid')
    end

    def pool?
      conf[:pool] && conf[:pool].size > 0
    end

    def conf_key
      :resque
    end
  end

  module AppServers
    def self.by_name(name)
      case name
      when 'unicorn'
        UnicornConf
      else
        raise "app_server #{name} not found"
      end
    end

    class AppServerConf < NestedConf
      def run?
        conf != nil && !conf.empty?
      end

      def stderr_log
      end

      def stdout_log
      end

      def socket_path
        ::File.join(app_conf.sockets_dir, "#{name}.sock")
      end

      def pid_file
        ::File.join(app_conf.pids_dir, "#{name}.pid")
      end

      def name
        self.class.name.split('::').last.downcase.sub(/conf$/, '')
      end

      def service_name
        "#{full_name}-#{name}"
      end

      def init_file
        "/etc/init.d/#{service_name}"
      end

      def conf_key
        :app_server
      end
    end

    class UnicornConf < AppServerConf
      def config_file
        ::File.join(app_conf.config_dir, 'unicorn.rb')
      end

      def stderr_log
        ::File.join(app_conf.log_dir, 'unicorn.stderr.log')
      end

      def stdout_log
        ::File.join(app_conf.log_dir, 'unicorn.stdout.log')
      end
    end
  end

end