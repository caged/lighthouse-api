require 'rubygems'
require 'activesupport'
require 'activeresource'

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
  class Error < StandardError; end
  class << self
    attr_accessor :email, :password, :host_format, :domain_format, :protocol, :port
    attr_reader :account, :token

    # Sets the account name, and updates all the resources with the new domain.
    def account=(name)
      resources.each do |klass|
        klass.site = klass.site_format % (host_format % [protocol, domain_format % name, ":#{port}"])
      end
      @account = name
    end

    # Sets up basic authentication credentials for all the resources.
    def authenticate(email, password)
      @email    = email
      @password = password
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
  
  self.host_format   = '%s://%s%s'
  self.domain_format = '%s.lighthouseapp.com'
  self.protocol      = 'http'
  self.port          = ''

  class Base < ActiveResource::Base
    def self.inherited(base)
      Lighthouse.resources << base
      class << base
        attr_accessor :site_format
      end
      base.site_format = '%s'
      super
    end
  end
  
  # Find projects
  #
  #   Lighthouse::Project.find(:all) # find all projects for the current account.
  #   Lighthouse::Project.find(44)   # find individual project by ID
  #
  # Creating a Project
  #
  #   project = Lighthouse::Project.new(:name => 'Ninja Whammy Jammy')
  #   project.save
  #   # => true
  #
  # Creating an OSS project
  # 
  #   project = Lighthouse::Project.new(:name => 'OSS Project')
  #   project.access = 'oss'
  #   project.license = 'mit'
  #   project.save
  # 
  # OSS License Mappings
  # 
  #   'mit' => "MIT License",
  #   'apache-2-0' => "Apache License 2.0",
  #   'artistic-gpl-2' => "Artistic License/GPLv2",
  #   'gpl-2' => "GNU General Public License v2",
  #   'gpl-3' => "GNU General Public License v3",
  #   'lgpl' => "GNU Lesser General Public License"
  #   'mozilla-1-1' => "Mozilla Public License 1.1"
  #   'new-bsd' => "New BSD License",
  #   'afl-3' => "Academic Free License v. 3.0"
  
  #
  # Updating a Project
  #
  #   project = Lighthouse::Project.find(44)
  #   project.name = "Lighthouse Issues"
  #   project.public = false
  #   project.save
  #
  # Finding tickets
  # 
  #   project = Lighthouse::Project.find(44)
  #   project.tickets
  #
  class Project < Base
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
    
    def changesets(options = {})
      Changeset.find(:all, :params => options.update(:project_id => id))
    end
  end

  class User < Base
    def memberships
      Membership.find(:all, :params => {:user_id => id})
    end
  end
  
  class Membership < Base
    site_format << '/users/:user_id'
    def save
      raise Error, "Cannot modify memberships from the API"
    end
  end
  
  class Token < Base
    def save
      raise Error, "Cannot modify Tokens from the API"
    end
  end

  # Find tickets
  #
  #  Lighthouse::Ticket.find(:all, :params => { :project_id => 44 })
  #  Lighthouse::Ticket.find(:all, :params => { :project_id => 44, :q => "state:closed tagged:committed" })
  #
  #  project = Lighthouse::Project.find(44)
  #  project.tickets
  #  project.tickets(:q => "state:closed tagged:committed")
  #
  # Creating a Ticket
  #
  #  ticket = Lighthouse::Ticket.new(:project_id => 44)
  #  ticket.title = 'asdf'
  #  ...
  #  ticket.tags << 'ruby' << 'rails' << '@high'
  #  ticket.save
  #
  # Updating a Ticket
  #
  #  ticket = Lighthouse::Ticket.find(20, :params => { :project_id => 44 })
  #  ticket.state = 'resolved'
  #  ticket.tags.delete '@high'
  #  ticket.save
  #
  class Ticket < Base
    attr_writer :tags
    site_format << '/projects/:project_id'

    def id
      attributes['number'] ||= nil
      number
    end

    def tags
      attributes['tag'] ||= nil
      @tags ||= tag.blank? ? [] : parse_with_spaces(tag)
    end

    def save_with_tags
      self.tag = @tags.collect do |tag|
        tag.include?(' ') ? tag.inspect : tag
      end.join(" ") if @tags.is_a?(Array)
      @tags = nil ; save_without_tags
    end
    
    alias_method_chain :save, :tags

    private
      # taken from Lighthouse Tag code
      def parse_with_spaces(list)
        tags = []

        # first, pull out the quoted tags
        list.gsub!(/\"(.*?)\"\s*/ ) { tags << $1; "" }
        
        # then, get whatever's left
        tags.concat list.split(/\s/)

        cleanup_tags(tags)
      end
    
      def cleanup_tags(tags)
        returning tags do |tag|
          tag.collect! do |t|
            unless tag.blank?
              t.downcase!
              t.gsub! /(^')|('$)/, ''
              t.gsub! /[^a-z0-9 \-_@\!']/, ''
              t.strip!
              t
            end
          end
          tag.compact!
          tag.uniq!
        end
      end
  end
  
  class Message < Base
    site_format << '/projects/:project_id'
  end
  
  class Milestone < Base
    site_format << '/projects/:project_id'
  end
  
  class Bin < Base
    site_format << '/projects/:project_id'
  end
  
  class Changeset < Base
    site_format << '/projects/:project_id'
  end
  
  class Change < Array; end
end

module ActiveResource
  class Connection
    private
      def authorization_header
        (Lighthouse.email || Lighthouse.password ? { 'Authorization' => 'Basic ' + ["#{Lighthouse.email}:#{Lighthouse.password}"].pack('m').delete("\r\n") } : {})
      end
  end
end