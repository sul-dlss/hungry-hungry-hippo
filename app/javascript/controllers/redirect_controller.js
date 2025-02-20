import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  redirect (event) {
    window.location = event.target.value
  }
}
