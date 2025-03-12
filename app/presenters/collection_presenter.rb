# frozen_string_literal: true

# Presents a collection
class CollectionPresenter < FormPresenter
  def initialize(collection:, collection_form:, version_status:)
    @collection = collection
    super(form: collection_form, version_status:)
  end

  attr_reader :collection

  delegate :license, to: :collection

  # @param [Symbol] role :managers or :depositors
  # @return [Array<String>] an array of formatted sunetids and names
  def participants(role)
    collection.send(role).map { |participant| "#{participant.sunetid}: #{participant.name}" }
  end

  def release
    return 'Immediately' if collection.immediate_release_option?

    duration_text = Collection::RELEASE_DURATION_OPTIONS.invert[collection.release_duration]
    "Depositor selects release date no more than #{duration_text}"
  end

  def visibility
    collection.access&.humanize
  end

  def doi_assignment
    collection.doi_option.humanize
  end

  def additional_terms_of_use
    case collection.custom_rights_statement_option
    when 'provided'
      collection.provided_custom_rights_statement
    when 'depositor_selects'
      "Allow user to enter with instructions:\n\n#{collection.custom_rights_statement_instructions}"
    else
      'No'
    end
  end

  def license_option_label
    license_label = License.find_by(id: collection.license)&.label

    case collection.license_option
    when 'required'
      "License required: #{license_label}"
    else
      "Depositor selects. Default license: #{license_label}"
    end
  end

  def review_workflow_status
    collection.review_enabled ? 'On' : 'Off'
  end

  def purl_link
    # No druid yet, so there's no PURL link yet either. Collection is likely still depositing.
    return if druid.blank?

    link_to_new_tab(nil, Sdr::Purl.from_druid(druid:))
  end

  def created_by
    collection.user.name
  end

  def created_datetime
    collection.created_at.localtime.strftime('%b %d, %Y, %l:%M%p %Z')
  end
end
