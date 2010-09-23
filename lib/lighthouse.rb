$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

require 'rubygems'
require 'lighthouse/core_ext/uri'
require 'active_resource'

# Ruby lib for working with the Lighthouse API's XML interface.  
# The first thing you need to set is the account name.  This is the same
# as the web address for your account.
#
#   Lighthouse.account = 'activereload'
#
# Then, you should set the authentication.  You can either use your login
# credentials with HTTP Basic Authentication or with an API Tokens.  You can
# find more info on tokens at http://lighthouseapp.com/help/using-beacons.
#
#   # with basic authentication
#   Lighthouse.authenticate('rick@techno-weenie.net', 'spacemonkey')
#
#   # or, use a token
#   Lighthouse.token = 'abcdefg'
#
# If no token or authentication info is given, you'll only be granted public access.
#
# This library is a small wrapper around the REST interface.  You should read the docs at
# http://lighthouseapp.com/api.
#
module Lighthouse
  
  extend ActiveSupport::Autoload
  
  autoload :Base
  autoload :Bin
  autoload :Changeset
  autoload :Membership
  autoload :Message
  autoload :Milestone
  autoload :Project
  autoload :ProjectMembership
  autoload :Tag
  autoload :TagResource
  autoload :Ticket
  autoload :Token
  autoload :User
  
  class Error < StandardError; end
  
  class Change < Array; end
  
  self.host_format   = '%s://%s%s'
  self.domain_format = '%s.lighthouseapp.com'
  self.protocol      = 'http'
  self.port          = ''
  
  class << self
    attr_accessor :password, :host_format, :domain_format, :protocol, :port
    attr_reader :account, :token, :email

    # Sets the account name, and updates all the resources with the new domain.
    def account=(name)
      resources.each do |klass|
        klass.site = klass.site_format % (host_format % [protocol, domain_format % name, ":#{port}"])
      end
      @account = name
    end

    # Sets up basic authentication credentials for all the resources.
    def authenticate(email, password)
      self.email    = email
      self.password = password
    end

    # Sets the API token for all the resources.
    def token=(value)
      resources.each do |klass|
        klass.headers['X-LighthouseToken'] = value
      end
      @token = value
    end
    
    # Sets the account email and user to avoid monkeypatching ActiveResource
    def email=(value)
      @email = @user = value
    end

    def resources
      @resources ||= []
    end
  end
end
