$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activesupport/lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activeresource/lib')
require 'active_support'
require 'active_resource'

module Lighthouse
  class Base < ActiveResource::Base
    def self.inherited(base)
      (self.resources ||= []) << base
      class << base
        def account
          Lighthouse::Base.account
        end

        def account=(name)
          Lighthouse::Base.account = name
        end

        def token
          Lighthouse::Base.token
        end

        def token=(value)
          Lighthouse::Base.token = value
        end
        
        attr_accessor :site_format
      end
      base.site_format = 'http://%s.lighthouseapp.com'
      super
    end
    
    class << self
      attr_accessor :resources, :account, :token

      def account=(name)
        resources.each do |klass|
          klass.site = klass.site_format % name
        end
        @account = name
      end

      def token=(value)
        resources.each do |klass|
          klass.custom_headers['X-LighthouseToken'] = value
        end
        @token = value
      end
    end
    
    def account
      self.class.account
    end
    
    def token
      self.class.token
    end
  end
  
  class Project < Lighthouse::Base
  end

  class Ticket < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
end