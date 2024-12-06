import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['contributorTypePerson', 'contributorTypeOrganization', 'selectPersonRole', 'selectOrganizationRole',
    'person', 'organization']

  connect () {
    this.contributorTypeChanged()
  }

  contributorTypeChanged () {
    if (this.contributorTypePersonTarget.checked) {
      this.selectPersonRoleTarget.hidden = false
      this.selectPersonRoleTarget.disabled = false
      this.selectOrganizationRoleTarget.hidden = true
      this.selectOrganizationRoleTarget.disabled = true
      this.displayPerson()
    } else {
      this.selectPersonRoleTarget.hidden = true
      this.selectPersonRoleTarget.disabled = true
      this.selectOrganizationRoleTarget.hidden = false
      this.selectOrganizationRoleTarget.disabled = false
      this.displayOrganization()
    }
  }

  // Person role in toggle is selected.
  displayPerson () {
    console.log('person')
    this.personTarget.hidden = false
    this.organizationTarget.hidden = true
  }

  // Organization role in toggle is selected.
  displayOrganization () {
    console.log('organization')
    this.organizationTarget.hidden = false
    this.personTarget.hidden = true
  }
}
