# frozen_string_literal: true

# Looks up data for organizations from the ROR service
class AffiliationsController < ApplicationController
  skip_verify_authorized only: %i[search]

  def search
    @organizations = lookup_organization
    return head :not_found if @organizations.empty?

    render layout: false
  end

  private

  def lookup_organization
    RorService.call(search: params[:query])
  end
end
