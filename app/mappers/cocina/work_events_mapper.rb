# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Cocina
  # Maps WorkForm to Cocina event parameters
  class WorkEventsMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    def initialize(work_form:)
      @work_form = work_form
    end

    # @return [Array] the Cocina event parameters
    def call
      [deposit_publication_date_event_params, creation_date_event_params, publication_date_event_params].compact
    end

    private

    attr_reader :work_form

    delegate :publication_date, :create_date_type, :create_date_single, :create_date_range_from,
             :create_date_range_to, to: :work_form

    def creation_date_event_params
      date = if create_date_type == 'single'
               create_date_single.to_s
             else
               [create_date_range_from, create_date_range_to].filter_map(&:to_s).join('/').presence
             end

      return if date.blank?

      DescriptionCocinaBuilder.event(type: 'creation', date:)
    end

    def publication_date_event_params
      date = publication_date.to_s

      return if date.blank?

      DescriptionCocinaBuilder.event(type: 'publication', primary: true, date:)
    end

    def deposit_publication_date_event_params
      return if work_form.deposit_publication_date.blank?

      DescriptionCocinaBuilder.event(type: 'deposit', date_type: 'publication',
                                     date: work_form.deposit_publication_date)
    end
  end
end
