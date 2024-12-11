# frozen_string_literal: true

# A proxy to Settings.autocomplete_lookup.url to get OCLC's FAST data for typeahead
class FastController < ApplicationController
  skip_verify_authorized only: %i[show]

  def show
    result = KeywordResolver.call(query: params.require(:q))
    @suggestions = result.value_or([])

    if result.success?
      return render status: :no_content if @suggestions.empty?

      render status: :ok, layout: false
    else
      logger.warn(result.failure)
      render status: :internal_server_error, html: ''
    end
  end
end
