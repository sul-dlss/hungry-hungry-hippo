# frozen_string_literal: true

module Collections
  module Edit
    # Select field for license
    class LicenseComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def license_options
        License::GROUPS.to_h do |group|
          licenses = License.where(group:).filter_map do |license|
            # Include all non-deprecated licenses
            [license.label, license.id] unless license.deprecated
          end
          [group, licenses]
        end
      end
    end
  end
end
