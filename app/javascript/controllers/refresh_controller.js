import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    setTimeout(() => {
      window.location.reload()
    }, 1500)
  }
}
