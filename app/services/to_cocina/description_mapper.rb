# frozen_string_literal: true

module ToCocina
  # Maps a WorkForm to a Cocina description
  class DescriptionMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    def initialize(work_form:)
      @work_form = work_form
    end

    # @return [Cocina::Models::Description, Cocina::Models::RequestDescription]
    def call
      # if work_form.druid.present?
      #   Cocina::Models::Description.new(params)

      # else
      Cocina::Models::RequestDescription.new(params)
      # end
    end

    private

    attr_reader :work_form

    def params
      {
        title: CocinaDescriptionSupport.title(title: work_form.title)
        # contributor: contributors_params.presence,
        # note: note_params.presence,
        # subject: subject_params.presence,
        # purl: Sdr::Purl.from_druid(druid: work_form.druid)
        # relatedResource: related_resource_params
      }.compact
    end

    # def contributors_params
    #   work_form.authors.map do |contributor|
    #     CocinaDescriptionSupport.person_contributor(
    #       forename: contributor.first_name,
    #       surname: contributor.last_name
    #     )
    #   end
    # end

    # def note_params
    #   [].tap do |params|
    #     if work_form.abstract.present?
    #       params << CocinaDescriptionSupport.note(type: 'abstract',
    #                                               value: work_form.abstract)
    #     end
    #   end
    # end
  end
end
