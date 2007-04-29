$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activesupport/lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activeresource/lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/actionmailer/lib')
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
      end
      super
    end
    
    class_inheritable_accessor :site_format
    self.site_format = 'http://%s.lighthouseapp.com'
    
    class << self
      attr_accessor :resources, :account

      def account=(name)
        resources.each do |klass|
          klass.site = klass.site_format % name
        end
        @account = name
      end
    end
    
    def account
      self.class.account
    end

    def account=(name)
      self.class.account = name
    end
  end
end

class Ticket < Lighthouse::Base
  site_format << '/projects/:project_id'
end