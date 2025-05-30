# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps deposit_publication date from Cocina to WorkForm
  class DepositPublicationDateMapper < BaseDateMapper
    def call
      first_cocina_event_date_of(type: 'deposit')&.value
    end
  end
end
