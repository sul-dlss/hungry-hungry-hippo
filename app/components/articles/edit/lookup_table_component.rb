# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the article details from a CrossRef lookup
    class LookupTableComponent < ApplicationComponent
      def initialize(article_work_form:, classes: [])
        @article_work_form = article_work_form
        @classes = classes
        super()
      end

      attr_reader :article_work_form, :classes

      delegate :title, to: :article_work_form

      def publication_date
        if article_work_form.publication_date.present?
          I18n.l(article_work_form.publication_date.to_date,
                 format: :long)
        else
          ''
        end
      end

      def authors
        article_work_form.contributors.map do |contributor|
          formatted_contributor(contributor)
        end.join(', ')
      end

      def abstract
        article_work_form.abstract.present? ? helpers.simple_format(article_work_form.abstract).html_safe : '' # rubocop:disable Rails/OutputSafety
      end

      def render?
        article_work_form.present?
      end

      private

      def formatted_contributor(contributor)
        "#{contributor.first_name} #{contributor.last_name}".tap do |name|
          name << " #{Settings.orcid.url}/#{contributor.orcid}" if contributor.orcid.present?
          name << " (#{contributor.affiliations.map(&:institution).join('; ')})" if contributor.affiliations.any?
        end
      end
    end
  end
end
