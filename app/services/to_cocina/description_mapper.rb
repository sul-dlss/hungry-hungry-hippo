# frozen_string_literal: true

module ToCocina
  # Maps a WorkForm to a Cocina description
  class DescriptionMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] form
    def initialize(form:)
      @form = form
    end

    # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
    def call
      if form.persisted?
        Cocina::Models::Description.new(params)
      else
        Cocina::Models::RequestDescription.new(params)
      end
    end

    private

    attr_reader :form

    def params
      {
        title: CocinaDescriptionSupport.title(title: form.title),
        # contributor: contributors_params.presence,
        note: note_params,
        # subject: subject_params.presence,
        purl: Sdr::Purl.from_druid(druid: form.druid),
        relatedResource: CocinaDescriptionSupport.related_links(related_links: form.related_links)
      }.compact
    end

    # def contributors_params
    #   form.authors.map do |contributor|
    #     CocinaDescriptionSupport.person_contributor(
    #       forename: contributor.first_name,
    #       surname: contributor.last_name
    #     )
    #   end
    # end

    def note_params
      [].tap do |params|
        if form.abstract.present?
          params << CocinaDescriptionSupport.note(type: 'abstract',
                                                  value: form.abstract)
        end
      end.presence
    end
  end
end
