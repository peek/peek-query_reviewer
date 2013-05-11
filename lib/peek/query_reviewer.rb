require 'peek/query_reviewer/version'
require 'peek/query_reviewer/controller_helpers'

module QueryReviewer
  def self.enable!
    Thread.current['query_reviewer_enabled'] = true
    CONFIGURATION['enabled']                 = true
    CONFIGURATION['profiling']               = true
    Thread.current['queries']              ||= SqlQueryCollection.new
  end

  def self.disable!
    Thread.current['query_reviewer_enabled'] = false
    CONFIGURATION['enabled']                 = false
    CONFIGURATION['profiling']               = false
    Thread.current['queries']                = nil
  end

  def self.load_configuration
    default_config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), "..", "query_reviewer_defaults.yml"))).result)

    CONFIGURATION.merge!(default_config['all'] || {})
    CONFIGURATION.merge!(default_config[Rails.env || 'test'] || {})

    # Peek defaults
    peek_config_file = File.expand_path('../../../config/query_reviewer.yml', __FILE__)

    if File.file?(peek_config_file)
      peek_config = YAML.load(ERB.new(IO.read(peek_config_file)).result)
      CONFIGURATION.merge!(peek_config['all'] || {})
      CONFIGURATION.merge!(peek_config[Rails.env || 'test'] || {})
    end

    # User can override default values if they choose
    app_config_file = File.join(Rails.root, 'config/query_reviewer.yml')

    if File.file?(app_config_file)
      app_config = YAML.load(ERB.new(IO.read(app_config_file)).result)
      CONFIGURATION.merge!(app_config['all'] || {})
      CONFIGURATION.merge!(app_config[Rails.env || 'test'] || {})
    end

    begin
      CONFIGURATION["uv"] ||= if Gem::Specification.respond_to?(:find_all_by_name)
        !Gem::Specification.find_all_by_name('uv').empty?
      else # RubyGems < 1.8.0
        !Gem.searcher.find('uv').nil?
      end

      if CONFIGURATION['uv']
        require 'uv'
      end
    rescue
      CONFIGURATION['uv'] ||= false
    end
  end
end

module Peek
  module QueryReviewer
    def self.setup
      ApplicationController.send(:include, Peek::QueryReviewer::ControllerHelpers)
    end

    def self.enable!
      ::QueryReviewer.enable!
    end

    def self.disable!
      ::QueryReviewer.disable!
    end
  end
end

# Query Reviewer extensions
require 'query_reviewer/query_warning'
require 'query_reviewer/array_extensions'
require 'query_reviewer/sql_query'
require 'query_reviewer/mysql_analyzer'
require 'query_reviewer/sql_sub_query'
require 'query_reviewer/mysql_adapter_extensions'
require 'query_reviewer/controller_extensions'
require 'query_reviewer/sql_query_collection'

require 'peek/views/query_reviewer'
require 'peek/query_reviewer/railtie'
