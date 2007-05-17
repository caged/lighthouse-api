$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activesupport/lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '../vendor/activeresource/lib')
require 'active_support'
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
  class << self
    attr_reader :account, :token

    # Sets the account name, and updates all the resources with the new domain.
    def account=(name)
      resources.each do |klass|
        klass.site = klass.site_format % name
      end
      @account = name
    end

    # Sets up basic authentication credentials for all the resources.
    def authenticate(user, password)
      resources.each do |klass|
        klass.site.user     = user
        klass.site.password = password
      end
    end

    # Sets the API token for all the resources.
    def token=(value)
      resources.each do |klass|
        klass.headers['X-LighthouseToken'] = value
      end
      @token = value
    end

    def resources
      @resources ||= []
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
  end
  
  # Find projects
  #
  #   Project.find(:all) # find all projects for the current account.
  #   Project.find(44)   # find individual project by ID
  #
  # Creating a Project
  #
  #   project = Project.new(:name => 'Ninja Whammy Jammy')
  #   project.save
  #   # => true
  #
  # Updating a Project
  #
  #   project = Project.find(44)
  #   project.name = "Lighthouse Issues"
  #   project.public = false
  #   project.save
  #
  # Finding tickets
  # 
  #   project = Project.find(44)
  #   project.tickets
  #
  class Project < Lighthouse::Base
    def tickets(options = {})
      Ticket.find(:all, :params => options.update(:project_id => id))
    end
  
    def messages(options = {})
      Message.find(:all, :params => options.update(:project_id => id))
    end
  
    def milestones(options = {})
      Milestone.find(:all, :params => options.update(:project_id => id))
    end
  
    def bins(options = {})
      Bin.find(:all, :params => options.update(:project_id => id))
    end
  end

  # Find tickets
  #
  #  Ticket.find(:all, :params => { :project_id => 44 })
  #  Ticket.find(:all, :params => { :project_id => 44, :q => "state:closed tagged:committed" })
  #
  #  project = Project.find(44)
  #  project.tickets
  #  project.tickets(:q => "state:closed tagged:committed")
  #
  # Creating a Ticket
  #
  #  ticket = Ticket.new(:project_id => 44)
  #  ticket.title = 'asdf'
  #  ...
  #  ticket.save
  #
  # Updating a Ticket
  #
  #  ticket = Ticket.find(20, :params => { :project_id => 44 })
  #  ticket.state = 'resolved'
  #  ticket.save
  #
  class Ticket < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
  
  class Message < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
  
  class Milestone < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
  
  class Bin < Lighthouse::Base
    site_format << '/projects/:project_id'
  end
end