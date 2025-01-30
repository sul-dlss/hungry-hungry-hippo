# frozen_string_literal: true

module CocinaParsers
  # Helpers for parsing Cocina Description
  class Description
    def self.title(...)
      new(...).title
    end

    def self.contact_emails(...)
      new(...).contact_emails
    end

    def initialize(cocina_object:)
      @cocina_object = cocina_object
    end

    def title
      cocina_object.description.title.first.value
    end

    def contact_emails
      ContactEmails.call(cocina_object:)
    end

    private

    attr_reader :cocina_object
  end
end
