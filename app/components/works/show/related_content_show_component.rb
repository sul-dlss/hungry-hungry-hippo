# frozen_string_literal: true

module Works
  module Show
    # Component for rendering related contents on the work show page
    class RelatedContentShowComponent < ApplicationComponent
      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super()
      end

      attr_reader :work_presenter

      def related_works
        work_presenter.related_works.select { |related_work| related_work.to_s.present? }
      end

      def relationship_label_for(related_work)
        t("related_works.edit.fields.relationship.options.#{related_work.relationship}")
      end
    end
  end
end
