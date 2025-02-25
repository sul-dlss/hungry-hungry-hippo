import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['collectionSection']

  connect () {
    this.toggleCollectionCheckboxes({ target: { value: '' } })
  }

  toggleCollectionCheckboxes (event) {
    const disabled = event.target.value !== 'Request access to another collection'
    this.collectionSectionTarget.classList.toggle('d-none', disabled)
    this.collectionSectionTarget.querySelectorAll('input').forEach(input => {
      input.disabled = disabled
    })
  }
}
