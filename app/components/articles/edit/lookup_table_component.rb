# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the article details from a CrossRef lookup
    class LookupTableComponent < ApplicationComponent
      def initialize(article_work_form:, form:, extracted_abstract:, classes: [])
        @article_work_form = article_work_form
        @form = form
        @extracted_abstract = extracted_abstract
        @classes = classes
        super()
      end

      attr_reader :article_work_form, :classes, :extracted_abstract, :form

      delegate :title, :content_id, to: :article_work_form

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

      def doi
        article_work_form.related_works.first.identifier
      end

      def render?
        article_work_form.present?
      end

      def show_crossref_abstract?
        abstract.present? || !Settings.extract_abstracts.enabled
      end

      def doi_identifier
        DoiSupport.identifier(doi)
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
