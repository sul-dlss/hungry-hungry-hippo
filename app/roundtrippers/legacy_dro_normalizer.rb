# Normnalizes legacy (H2) DROs to be compatible with H3 cocina.
class LegacyDroNormalizer
  def self.call(...)
    new(...).call
  end

  def initialize(cocina_object:, document: false)
    @cocina_object = cocina_object
    @document = document
  end

  def call
    # normalize_location
    # normalize_files
    normalize_events
    normalize_document
    normalize_use_statement
    # normalize_copyright
    # normalize_message_digests
    normalize_contributor
    # normalize_event_contributor
    # normalize_preferred_citation
    # normalize_admin_metadata
    # normalize_subjects
    # normalize_access_contacts

    norm_cocina_object = Cocina::Models.build(cocina_attrs)
    Cocina::Models.with_metadata(norm_cocina_object, cocina_object.lock, created: cocina_object.created,
                                                                         modified: cocina_object.modified)
  end

  # H2 changes:
  # * Remove deposit events <-- Still unclear if this are needed.

  private

  attr_reader :cocina_object

  def cocina_attrs
    @cocina_attrs ||= Cocina::Models.without_metadata(cocina_object).to_h
  end

  def normalize_location
    # Remove nil location fields
    cocina_attrs[:access].compact!
    cocina_attrs.dig(:access, :embargo)&.compact!
    Array(cocina_attrs.dig(:structural, :contains)).each do |file_set_attrs|
      Array(file_set_attrs.dig(:structural, :contains)).each do |file_attrs|
        file_attrs[:access].compact!
      end
    end
  end

  def normalize_events
    # Remove deposit events and events without dates
    events_attrs = cocina_attrs.dig(:description, :event)
    return if events_attrs.blank?

    cocina_attrs[:description][:event] = events_attrs.reject do |event_attrs|
      event_attrs[:type] == 'deposit' # || event_attrs[:date].blank?
    end
    cocina_attrs[:description].delete(:event) if cocina_attrs[:description][:event].empty?
  end

  def normalize_files
    # File versions should match the version of the cocina object
    Array(cocina_attrs.dig(:structural, :contains)).each do |file_set_attrs|
      file_set_attrs[:version] = cocina_object.version
      Array(file_set_attrs.dig(:structural, :contains)).each do |file_attrs|
        file_attrs[:label] = file_set_attrs[:label]
        file_attrs[:version] = cocina_object.version
        # If access is world, file access should be world.
        if cocina_attrs.dig(:access, :view) == 'world'
          file_attrs[:access][:view] = 'world'
          file_attrs[:access][:download] = 'world'
        end
        # This will remove null use and languageTag fields
        file_attrs.compact!
      end
    end
  end

  def normalize_document
    # H2 doesn't set the object type to document for PDFs; H3 does.
    return unless document?

    cocina_attrs[:type] = Cocina::Models::ObjectType.document
    Array(cocina_attrs.dig(:structural, :contains)).each do |file_set_attrs|
      file_set_attrs[:version] = cocina_object.version

      # Assuming one file per fileset.
      file_attrs = file_set_attrs.dig(:structural, :contains, 0)
      file_set_attrs[:type] = Cocina::Models::FileSetType.document if document_file?(file_attrs)
    end
  end

  def document_file?(file_attrs)
    file_attrs[:hasMimeType] == 'application/pdf' && file_attrs.dig(:administrative, :publish) == true
  end

  def document?
    @document
  end

  def normalize_use_statement
    # Add default useAndReproductionStatement if not present
    # use_statement = cocina_attrs.dig(:access, :useAndReproductionStatement)
    custom_statement = TermsOfUseSupport.custom_rights_statement(use_statement: cocina_attrs.dig(:access,
                                                                                                 :useAndReproductionStatement))
    cocina_attrs[:access][:useAndReproductionStatement] =
      TermsOfUseSupport.full_statement(custom_rights_statement: custom_statement)
  end

  def normalize_copyright
    cocina_attrs[:access].delete(:copyright)
  end

  def normalize_message_digests
    Array(cocina_attrs.dig(:structural, :contains)).each do |file_set_attrs|
      Array(file_set_attrs.dig(:structural, :contains)).each do |file_attrs|
        file_attrs[:hasMessageDigests].sort_by! { |digest| digest[:type] }
      end
    end
  end

  def normalize_contributor
    Array(cocina_attrs.dig(:description, :contributor)).each do |contributor_attrs|
      # Delete publisher role
      contributor_attrs.delete(:role) if contributor_attrs.dig(:role, 0, :code) == 'pbl'

      # Delete affiliation notes
      # notes_attrs = Array(contributor_attrs[:note]).reject { |note_attrs| note_attrs[:type] == 'affiliation' }
      # if notes_attrs.empty?
      #   contributor_attrs.delete(:note)
      # else
      #   contributor_attrs[:note] = notes_attrs
      # end

      # Add ROR for Stanford degree granting institutions
      next unless contributor_attrs.dig(:name, 0, :value) == 'Stanford University' &&
                  contributor_attrs.dig(:role, 0, :code) == 'dgg'

      contributor_attrs[:identifier] = [{ type: 'ROR', uri: 'https://ror.org/00f54p054', source: { code: 'ror' } }]
    end
  end

  def normalize_event_contributor
    # Remove event contributor (which is a publisher)
    Array(cocina_attrs.dig(:description, :event)).each { |event_attrs| event_attrs.delete(:contributor) }
  end

  def normalize_preferred_citation
    if (note = cocina_attrs.dig(:description, :note).find { |note_attrs| note_attrs[:type] == 'preferred citation' })
      note.delete(:displayLabel)
    end
  end

  def normalize_admin_metadata
    return unless cocina_attrs.dig(:description, :adminMetadata, :event, 0, :date, 0, :encoding, :code) == 'w3cdtf'

    cocina_attrs[:description][:adminMetadata][:event][0][:date][0][:encoding][:code] = 'edtf'
  end

  def normalize_subjects
    # Deduplicate
    cocina_attrs[:description][:subject]&.uniq! { |subject| subject[:value] }
  end

  def normalize_access_contacts
    # Deduplicate
    cocina_attrs.dig(:description, :access, :accessContact)&.uniq! { |contact| contact[:value] }
  end
end
