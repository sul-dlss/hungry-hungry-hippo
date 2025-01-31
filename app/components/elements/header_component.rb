# frozen_string_literal: true

module Elements
  # SUL application header, taken from component library
  class HeaderComponent < ViewComponent::Base
    # List of links to display in the header
    def nav_links
      [
        { title: 'Contact us', path: root_path }, # TODO: #15
        { title: 'Help', path: 'https://sdr.library.stanford.edu/documentation' },
        { title: 'Why SDR?', path: 'https://sdr.library.stanford.edu/' },
        { title: 'Terms of deposit', path: root_path } # TODO: #448
      ]
    end
  end
end
