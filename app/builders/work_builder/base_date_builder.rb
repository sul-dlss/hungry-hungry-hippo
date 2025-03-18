# frozen_string_literal: true

class WorkBuilder
  # Base class for building work form dates from Cocina objects
  class BaseDateBuilder < BaseBuilder
    private

    def first_cocina_event_date_of(type:)
      event = cocina_object.description.event.find { |e| e.type == type }
      return if event.blank?

      cocina_date = event.date.first
      return unless cocina_date&.encoding&.code == 'edtf'

      cocina_date
    end

    def event_params_for(cocina_date:)
      date = Date.edtf!(cocina_date.value)
      # Using count of dashes to determine the date parts present
      dash_count = cocina_date.value.count('-')
      { year: date.year }.tap do |date_params|
        date_params[:month] = date.month if dash_count >= 1
        date_params[:day] = date.day if dash_count == 2
        date_params[:approximate] = cocina_date.qualifier == 'approximate'
      end
    end
  end
end
