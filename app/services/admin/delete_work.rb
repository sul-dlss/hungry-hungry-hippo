# frozen_string_literal: true

module Admin
  # Delete a work
  class DeleteWork
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:, work:)
      @work_form = work_form
      @work = work
    end

    def call
      work.destroy!
    end

    private

    attr_reader :work_form, :work
  end
end
