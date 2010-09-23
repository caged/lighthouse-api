module Lighthouse
  class Base < ActiveResource::Base
    def self.inherited(base)
      Lighthouse.resources << base
      class << base
        attr_accessor :site_format
      end
      base.site_format = '%s'
      super
      Lighthouse.update_site(base)
      Lighthouse.update_token_header(base)
    end
  end
end
