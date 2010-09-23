module Lighthouse
  class ProjectMembership < Base
    self.element_name = 'membership'
    site_format << '/projects/:project_id'

    def url
      respond_to?(:account) ? account : project
    end

    def save
      raise Error, "Cannot modify memberships from the API"
    end
  end
end
