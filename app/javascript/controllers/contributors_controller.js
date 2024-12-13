import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['contributorTypePerson', 'contributorTypeOrganization', 'contributorTypePersonLabel', 'contributorTypeOrganizationLabel',
    'selectPersonRole', 'selectOrganizationRole', 'personName', 'organizationName', 'orcidField']

  static values = {
    orcid: String
  }

  connect () {
    if (this.contributorTypeOrganizationTarget.checked) {
      this.contributorTypeOrganizationSelected()
    } else {
      this.contributorTypePersonSelected()
    }
  }

  useOrcid () {
    this.orcidFieldTarget.value = this.orcidValue
  }

  // Role type toggle Individual selection
  contributorTypePersonSelected () {
    this.contributorTypeOrganizationTarget.checked = false
    this.contributorTypePersonTarget.checked = true
    this.contributorTypePersonLabelTarget.classList.replace('btn-outline-primary', 'btn-primary')
    this.contributorTypeOrganizationLabelTarget.classList.replace('btn-primary', 'btn-outline-primary')
    this.selectPersonRoleTarget.hidden = false
    this.selectPersonRoleTarget.disabled = false
    this.selectOrganizationRoleTarget.hidden = true
    this.selectOrganizationRoleTarget.disabled = true
    this.displayPerson()
  }

  // Role type toggle Organization selection
  contributorTypeOrganizationSelected () {
    this.contributorTypeOrganizationTarget.checked = true
    this.contributorTypePersonTarget.checked = false
    this.contributorTypeOrganizationLabelTarget.classList.replace('btn-outline-primary', 'btn-primary')
    this.contributorTypePersonLabelTarget.classList.replace('btn-primary', 'btn-outline-primary')
    this.selectPersonRoleTarget.hidden = true
    this.selectPersonRoleTarget.disabled = true
    this.selectOrganizationRoleTarget.hidden = false
    this.selectOrganizationRoleTarget.disabled = false
    this.displayOrganization()
  }

  // Person role in toggle is selected.
  displayPerson () {
    this.personNameTarget.hidden = false
    this.organizationNameTarget.hidden = true
  }

  // Organization role in toggle is selected.
  displayOrganization () {
    this.organizationNameTarget.hidden = false
    this.personNameTarget.hidden = true
  }
}
