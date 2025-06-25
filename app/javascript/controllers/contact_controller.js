import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['collectionSection', 'helpHow']

  connect () {
    this.toggleCollectionCheckboxes()
  }

  toggleCollectionCheckboxes () {
    const disabled = this.helpHowTarget.value !== 'Request access to another collection'
    this.collectionSectionTarget.classList.toggle('d-none', disabled)
    this.collectionSectionTarget.querySelectorAll('input').forEach(input => {
      input.disabled = disabled
    })
  }
}
