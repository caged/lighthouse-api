$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activesupport/lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activeresource/lib')
require 'active_support'
require 'active_resource'

module Lighthouse
  class << self
    attr_reader :account, :token

    def resources
      @resources ||= []
    end

    def account=(name)
      resources.each do |klass|
        klass.site = klass.site_format % name
      end
      @account = name
    end

    def token=(value)
      resources.each do |klass|
        klass.headers['X-LighthouseToken'] = value
      end
      @token = value
    end
  end

  class Base < ActiveResource::Base
    def self.inherited(base)
      Lighthouse.resources << base
      class << base
        attr_accessor :site_format
      end
      base.site_format = 'http://%s.lighthouseapp.com'
      super
    end
    
    def account
      Lighthouse.account
    end
    
    def token
      Lighthouse.token
    end
  end
  
  class Project < Lighthouse::Base
  end

  class Ticket < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
end