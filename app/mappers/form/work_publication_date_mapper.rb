# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps publication date from Cocina to WorkForm
  class WorkPublicationDateMapper < BaseDateMapper
    def call
      cocina_date = first_cocina_event_date_of(type: 'publication')
      return {} if cocina_date.nil?

      # Publication date is always a single date
      event_params_for(cocina_date:)
    end
  end
end
