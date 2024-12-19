# frozen_string_literal: true

# Lookup a contributor in ORCID and return their name information
class OrcidController < ApplicationController
  before_action :skip_authorization, only: %i[search]

  def search
    result = OrcidResolver.call(orcid_id: params[:id])

    if result.success?
      render json: { orcid: params[:id], first_name: result.value![0], last_name: result.value![1] }
    else
      head result.failure
    end
  end
end
