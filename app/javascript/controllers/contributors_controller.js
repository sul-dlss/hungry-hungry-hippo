import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'personOption', 'organizationOption',
    'personSection', 'organizationSection',
    'degreeGrantingSection', 'notDegreeGrantingSection',
    'orcidField', 'useOrcidButton', 'resetOrcidButton',
    'firstNameField', 'lastNameField',
    'organizationRoleSelect', 'yesStanfordOption',
    'degreeGrantingSuborganizationSection', 'degreeGrantingOrganizationSection'
  ]

  static values = {
    orcid: String,
    orcidPrefix: String,
    orcidResolverPath: String
  }

  connect () {
    if (this.organizationOptionTarget.checked) {
      this.showOrganizationSection()
    } else {
      this.showPersonSection()
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

  // Role type toggle Person selection
  showPersonSection () {
    this.toggleInputs(this.personSectionTarget, false)
    this.toggleInputs(this.organizationSectionTarget, true)
    this.personSectionTarget.classList.remove('d-none')
    this.organizationSectionTarget.classList.add('d-none')
  }

  // Role type toggle Organization selection
  showOrganizationSection () {
    this.toggleInputs(this.personSectionTarget, true)
    this.toggleInputs(this.organizationSectionTarget, false)
    this.personSectionTarget.classList.add('d-none')
    this.organizationSectionTarget.classList.remove('d-none')
    this.showDegreeGrantingSection()
  }

  showDegreeGrantingSection () {
    if (this.organizationRoleSelectTarget.value === 'degree_granting_institution') {
      this.degreeGrantingSectionTarget.classList.remove('d-none')
      this.notDegreeGrantingSectionTarget.classList.add('d-none')
      this.toggleInputs(this.degreeGrantingSectionTarget, false)
      this.toggleInputs(this.notDegreeGrantingSectionTarget, true)
      if (this.yesStanfordOptionTarget.checked) {
        this.showDegreeGrantingSuborganizationSection()
      } else {
        this.showDegreeGrantingOrganizationSection()
      }
    } else {
      this.degreeGrantingSectionTarget.classList.add('d-none')
      this.notDegreeGrantingSectionTarget.classList.remove('d-none')
      this.toggleInputs(this.degreeGrantingSectionTarget, true)
      this.toggleInputs(this.notDegreeGrantingSectionTarget, false)
    }
  }

  showDegreeGrantingOrganizationSection () {
    this.degreeGrantingOrganizationSectionTarget.classList.remove('d-none')
    this.degreeGrantingSuborganizationSectionTarget.classList.add('d-none')
    this.toggleInputs(this.degreeGrantingOrganizationSectionTarget, false)
    this.toggleInputs(this.degreeGrantingSuborganizationSectionTarget, true)
  }

  showDegreeGrantingSuborganizationSection () {
    this.degreeGrantingOrganizationSectionTarget.classList.add('d-none')
    this.degreeGrantingSuborganizationSectionTarget.classList.remove('d-none')
    this.toggleInputs(this.degreeGrantingOrganizationSectionTarget, true)
    this.toggleInputs(this.degreeGrantingSuborganizationSectionTarget, false)
  }

  toggleInputs (sectionEl, disabled) {
    sectionEl.querySelectorAll('input, select').forEach(input => {
      input.disabled = disabled
    })
  }
}
