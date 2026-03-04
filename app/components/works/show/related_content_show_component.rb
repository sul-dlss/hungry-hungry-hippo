# frozen_string_literal: true

module Works
  module Show
    # Component for rendering related contents on the work show page
    class RelatedContentShowComponent < ApplicationComponent
      include LinkHelper

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

      # Returns a link if the related work is a URL, otherwise returns the related work
      # param related_work [RelatedWorkForm] the related work to generate a label for
      # return [String, RelatedWorkForm] a link if the related work is a URL, otherwise the related work
      def label_for(related_work)
        label = related_work.to_s
        uri = URI.parse(label)
        return label unless %w[http https].include?(uri.scheme)

        link_to_new_tab label, label
      rescue URI::InvalidURIError, URI::BadURIError
        related_work
      end

      def label
        'Related published work'
      end
    end
  end
end
