import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'personOption', 'organizationOption',
    'personSection', 'organizationSection',
    'degreeGrantingSection', 'notDegreeGrantingSection',
    'orcidInput', 'orcidFirstNameInput', 'orcidLastNameInput',
    'orcidMessage', 'orcidFeedback',
    'organizationRoleSelect', 'yesStanfordOption',
    'degreeGrantingSuborganizationSection', 'degreeGrantingOrganizationSection',
    'orcidSection', 'notOrcidSection', 'yesOrcidOption'
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

  useMyOrcid () {
    this.orcidInputTarget.value = this.orcidValue
    this.resolveOrcid()
  }

  resolveOrcid () {
    // Clear existing.
    this.orcidFeedbackTarget.textContent = ''
    this.orcidFeedbackTarget.classList.remove('is-invalid')
    this.orcidFirstNameInputTarget.disabled = true
    this.orcidFirstNameInputTarget.dataset.disabled = 'true'
    this.orcidFirstNameInputTarget.value = ''
    this.orcidLastNameInputTarget.disabled = true
    this.orcidLastNameInputTarget.dataset.disabled = 'true'
    this.orcidLastNameInputTarget.value = ''
    this.orcidMessageTarget.textContent = ''

    // Normalize
    const orcid = this.orcidInputTarget.value.replace(this.orcidPrefixValue, '')
    // 0000-0003-1527-0030
    if (orcid.length !== 19) return

    if (!/^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$/.test(orcid)) {
      this.orcidFeedbackTarget.classList.add('is-invalid')
      this.orcidFeedbackTarget.textContent = 'invalid ORCID iD'
      return
    }
    this.orcidInputTarget.value = orcid

    fetch(`${this.orcidResolverPathValue}${orcid}`)
      .then(response => {
        if (response.status === 404) {
          this.orcidFeedbackTarget.classList.add('is-invalid')
          this.orcidFeedbackTarget.textContent = 'not found'
          return null
        }
        if (!response.ok) throw new Error(response.status)
        return response.json()
      })
      .then(data => {
        if (!data) return
        this.orcidFirstNameInputTarget.disabled = false
        this.orcidFirstNameInputTarget.dataset.disabled = 'false'
        this.orcidFirstNameInputTarget.value = data.first_name
        this.orcidLastNameInputTarget.disabled = false
        this.orcidLastNameInputTarget.dataset.disabled = 'false'
        this.orcidLastNameInputTarget.value = data.last_name
        this.orcidMessageTarget.textContent = `Name associated with this ORCID iD is ${data.first_name} ${data.last_name}.`
      })
      .catch(error => console.dir(error))
  }

  // Role type toggle Person selection
  showPersonSection () {
    this.toggleDisplay(this.personSectionTarget, this.organizationSectionTarget)
    if (this.yesOrcidOptionTarget.checked) {
      this.showOrcidSection()
    } else {
      this.showNotOrcidSection()
    }
  }

  // Role type toggle Organization selection
  showOrganizationSection () {
    this.toggleDisplay(this.organizationSectionTarget, this.personSectionTarget)
    this.showDegreeGrantingSection()
  }

  showDegreeGrantingSection () {
    if (this.organizationRoleSelectTarget.value === 'degree_granting_institution') {
      this.toggleDisplay(this.degreeGrantingSectionTarget, this.notDegreeGrantingSectionTarget)
      if (this.yesStanfordOptionTarget.checked) {
        this.showDegreeGrantingSuborganizationSection()
      } else {
        this.showDegreeGrantingOrganizationSection()
      }
    } else {
      this.toggleDisplay(this.notDegreeGrantingSectionTarget, this.degreeGrantingSectionTarget)
    }
  }

  showDegreeGrantingOrganizationSection () {
    this.toggleDisplay(this.degreeGrantingOrganizationSectionTarget, this.degreeGrantingSuborganizationSectionTarget)
  }

  showDegreeGrantingSuborganizationSection () {
    this.toggleDisplay(this.degreeGrantingSuborganizationSectionTarget, this.degreeGrantingOrganizationSectionTarget)
  }

  showOrcidSection () {
    this.toggleDisplay(this.orcidSectionTarget, this.notOrcidSectionTarget)
  }

  showNotOrcidSection () {
    this.toggleDisplay(this.notOrcidSectionTarget, this.orcidSectionTarget)
  }

  toggleDisplay (showTarget, hideTarget) {
    showTarget.classList.remove('d-none')
    hideTarget.classList.add('d-none')
    this.toggleInputs(showTarget, false)
    this.toggleInputs(hideTarget, true)
  }

  toggleInputs (sectionEl, disabled) {
    sectionEl.querySelectorAll('input, select').forEach(input => {
      // This provides a way to keep intentionally disabled inputs disabled.
      if (!disabled && input.disabled && input.dataset.disabled === 'true') return
      input.disabled = disabled
    })
  }
}
