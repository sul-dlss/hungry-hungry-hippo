# frozen_string_literal: true

class WorkBuilder
  # Builds creation date from Cocina to WorkForm
  class CreationDateBuilder < BaseDateBuilder
    def call
      cocina_date = first_cocina_event_date_of(type: 'creation')
      return {} if cocina_date.nil?

      if single_date?(cocina_date:)
        single_date_params_for(cocina_date:)
      else
        range_date_params_for(cocina_date:)
      end
    end

    private

    def single_date?(cocina_date:)
      cocina_date.value.present?
    end

    def single_date_params_for(cocina_date:)
      { create_date_single_attributes: event_params_for(cocina_date:), create_date_type: 'single' }
    end

    def range_date_params_for(cocina_date:)
      from_params = event_params_for(cocina_date: cocina_date.structuredValue.find { |date| date.type == 'start' })
      to_params = event_params_for(cocina_date: cocina_date.structuredValue.find { |date| date.type == 'end' })
      if cocina_date.qualifier == 'approximate'
        from_params[:approximate] = true
        to_params[:approximate] = true
      end
      {
        create_date_range_from_attributes: from_params,
        create_date_range_to_attributes: to_params,
        create_date_type: 'range'
      }
    end
  end
end
