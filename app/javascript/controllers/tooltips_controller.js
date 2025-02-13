import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap' // eslint-disable-line no-unused-vars

export default class extends Controller {
  static targets = ["icon"]

  iconTargetConnected(element) {
    new bootstrap.Tooltip(element)
  }
}
