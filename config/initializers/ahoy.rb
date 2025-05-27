# frozen_string_literal: true

module Ahoy
  # Store for Ahoy tracking
  class Store < Ahoy::DatabaseStore
    def authenticate(data)
      # disables automatic linking of visits and users for privacy
    end
  end
end

# Mask IPs for privacy
Ahoy.mask_ips = true

# set to true for JavaScript tracking
Ahoy.api = true

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
