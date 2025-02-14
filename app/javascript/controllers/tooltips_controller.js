import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static targets = ['icon']

  iconTargetConnected (element) {
    return new bootstrap.Tooltip(element)
  }
}
