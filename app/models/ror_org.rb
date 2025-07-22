# frozen_string_literal: true

# Model for RoR organization
class RorOrg
  attr_accessor :id, :name, :city, :country, :aliases, :org_types

  def initialize(data)
    @id = data['id']
    @name = data['name']
    @city = data['addresses']&.first&.dig('city')
    @country = data.dig('country', 'country_name')
    # some orgs have lots of aliases (eg. https://ror.org/02vzbm991), this keeps it sane for display
    @aliases = data['aliases']&.first(3)&.join(', ')
    @org_types = data['types']&.join(', ')
  end

  def location
    [city, country].compact.join(', ')
  end
end
