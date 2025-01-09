# frozen_string_literal: true

# Presenter for licenses
class LicensePresenter
  # @return [Hash] options structure for licenses grouped by license group
  def self.options(current_license: nil)
    License::GROUPS.to_h do |group|
      licenses = License.where(group:).filter_map do |license|
        # Include all non-deprecated licenses and the current license (even if deprecated).
        [license.label, license.id] if !license.deprecated || license.id == current_license
      end
      [group, licenses]
    end
  end
end
