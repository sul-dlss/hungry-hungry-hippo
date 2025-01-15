# frozen_string_literal: true

# Efficiently determines if a DOI has been assigned to a work.
class DoiAssignedService
  def self.call(...)
    new(...).call
  end

  def initialize(cocina_object:, work:)
    @cocina_object = cocina_object
    @work = work
  end

  # return true if the work has a DOI assigned
  def call
    # If there is no DOI in the Cocina object, then a DOI definitely has not been assigned.
    return false unless doi_in_cocina?

    # Once a DOI is assigned (as determined by checking Datacite),
    # the Work record's doi_assigned attribute is set to true.
    # This is done to avoid checking Datacite every time the Work is accessed (slow!).
    # The way DOI assignment works is:
    # 1. The Cocina object gets a DOI. This may be done when the object is registered or by an update.
    # 2. When the object is accessioned, the update DOI step registers the DOI with Datacite.
    # Thus, having a DOI in the Cocina object does not mean it is registered with Datacite.
    # The only way to know for sure is to check Datacite.
    return true if work.doi_assigned?

    # This checks Datacite.
    assigned = Doi.assigned?(druid: work.druid)

    # So that next time don't have to check Datacite.
    work.update!(doi_assigned: true) if assigned
    assigned
  end

  private

  attr_reader :cocina_object, :work

  def doi_in_cocina?
    CocinaSupport.doi_for(cocina_object:).present?
  end
end
