# frozen_string_literal: true

module CocinaParsers
  class Description
    # Maps the value from the accessContact field in the Cocina::DescriptiveAccessMetadata object.
    # to the email value for a contact_email in the WorkForm
    class ContactEmails
      def self.call(...)
        new(...).call
      end

      def initialize(cocina_object:)
        @cocina_object = cocina_object
      end

      # @return [Array<String>] with keys for email
      def call
        return [] if cocina_object.description.access.blank?

        cocina_object.description.access.accessContact.filter_map do |access_contact|
          next if access_contact.value.blank?

          access_contact[:value]
        end
      end

      private

      attr_reader :cocina_object
    end
  end
end
