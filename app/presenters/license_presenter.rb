# frozen_string_literal: true

# Presenter for licenses
class LicensePresenter
  def initialize(collection:, work_form:)
    @collection = collection
    @work_form = work_form
  end

  # @return [Hash] options structure for licenses grouped by license group
  def options
    License::GROUPS.to_h do |group|
      licenses = License.where(group:).filter_map do |license|
        # Include all non-deprecated licenses and the current license (even if deprecated).
        [license.label, license.id] if !license.deprecated || license.id == current_license
      end
      [group, licenses]
    end
  end

  def label
    License.find_by(id: current_license)&.label
  end

  delegate :required_license_option?, to: :@collection

  private

  attr_reader :collection, :work_form

  def current_license
    work_form.license
  end
end
