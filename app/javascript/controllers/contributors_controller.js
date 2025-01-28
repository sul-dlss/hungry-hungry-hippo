import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'contributorTypePerson', 'contributorTypeOrganization',
    'contributorTypeOrganizationLabel', 'selectPersonRole', 'selectOrganizationRole', 'personName',
    'organizationName', 'orcidField', 'useOrcidButton', 'resetOrcidButton', 'firstNameField',
    'lastNameField'
  ]

  static values = {
    orcid: String,
    orcidPrefix: String,
    orcidResolverPath: String
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
    this.normalizeAndResolveOrcid()
    this.orcidFieldTarget.readOnly = true
    this.useOrcidButtonTarget.hidden = true
    this.resetOrcidButtonTarget.hidden = false
  }

  resetOrcid () {
    this.resetOrcidButtonTarget.hidden = true
    this.orcidFieldTarget.value = ''
    this.orcidFieldTarget.readOnly = false
    this.useOrcidButtonTarget.hidden = false
  }

  normalizeAndResolveOrcid () {
    this.orcidFieldTarget.value = this.orcidFieldTarget.value.replace(this.orcidPrefixValue, '')

    fetch(`${this.orcidResolverPathValue}${this.orcidFieldTarget.value}`)
      .then(response => {
        if (!response.ok) throw new Error(response.status)
        return response.json()
      })
      .then(data => {
        if (this.firstNameFieldTarget.value === '') this.firstNameFieldTarget.value = data.first_name
        if (this.lastNameFieldTarget.value === '') this.lastNameFieldTarget.value = data.last_name
      })
      .catch(error => console.dir(error))
  }

  // Role type toggle Individual selection
  contributorTypePersonSelected () {
    this.selectPersonRoleTarget.hidden = false
    this.selectPersonRoleTarget.disabled = false
    this.selectOrganizationRoleTarget.hidden = true
    this.selectOrganizationRoleTarget.disabled = true
    this.displayPerson()
  }

  // Role type toggle Organization selection
  contributorTypeOrganizationSelected () {
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
