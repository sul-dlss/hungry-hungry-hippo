# frozen_string_literal: true

module Collections
  # Component for editing collection contributors
  class ContributorComponent < Elements::Forms::TextFieldComponent
    def initialize(**args)
      args[:field_name] = :sunetid
      args[:label] = 'SUNet ID'
      super
    end
  end
end
