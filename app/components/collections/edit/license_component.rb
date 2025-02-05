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

      def field_name
        :license
      end

      def label
        helpers.t('license.edit.fields.label')
      end

      def help_text
        helpers.t('collections.edit.fields.license.help_text')
      end

      def license_options
        License::GROUPS.to_h do |group |
          licenses = License.where(group:).filter_map do |license|
            # Include all non-deprecated licenses and the current license (even if deprecated).
            [license.label, license.id] if !license.deprecated || license.id == current_license
          end
          [group, licenses]
        end
      end

      def current_license
        # TODO
        # form.license || '' # Treat nil as no license ('')
        ''
      end
    end
  end
end
