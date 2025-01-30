import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['form-date']

  reset () {
    this.formDateOutlets.forEach(outlet => outlet.reset())
  }
}
