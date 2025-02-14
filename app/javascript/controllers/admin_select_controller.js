import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['frame', 'body']

  changeFunction (event) {
    if (event.target.value === '') {
      this.bodyTarget.classList.add('d-none')
    } else {
      this.bodyTarget.classList.remove('d-none')
      this.frameTarget.src = event.target.value
    }
  }
}
