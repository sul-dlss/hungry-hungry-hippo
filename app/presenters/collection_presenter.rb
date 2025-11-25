# frozen_string_literal: true

# Presents a collection
class CollectionPresenter < FormPresenter
  include ActionPolicy::Behaviour

  def initialize(collection:, collection_form:, version_status:)
    @collection = collection
    super(form: collection_form, version_status:)
  end

  attr_reader :collection

  delegate :license, to: :collection

  def collection_form
    # Get the object being delegated to (since this is a SimpleDelegator)
    __getobj__
  end

  # @param [Symbol] role :managers or :depositors
  # @return [Array<String>] an array of formatted sunetids and names
  def participants(role)
    collection.send(role).map { |participant| user_display(participant) }
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

  def custom_rights_allowed
    %w[provided depositor_selects].include?(collection.custom_rights_statement_option) ? 'yes' : 'no'
  end

  def custom_rights_provided
    collection.provided_custom_rights_statement.present? ? 'yes' : 'no'
  end

  def custom_rights_statement_instructions_provided
    collection.custom_rights_statement_instructions.present? ? 'yes' : 'no'
  end

  def license_label
    @license_label ||= License.find_by(id: collection.license)&.label
  end

  def license_option_label
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
    user_display(collection.user)
  end

  def created_datetime
    collection.created_at.localtime.strftime('%b %d, %Y, %l:%M%p %Z')
  end

  def contact_emails
    collection_form.contact_emails.map(&:email).join(', ')
  end

  def related_links
    return ['None provided'] if collection_form.related_links.blank?

    collection_form.related_links.filter_map do |related_link|
      next if related_link.url.blank?

      link_to_new_tab(related_link.text || related_link.url, related_link.url)
    end
  end

  def editable?
    super && allowed_to?(:edit?, collection, context: { user: Current.user })
  end
end
