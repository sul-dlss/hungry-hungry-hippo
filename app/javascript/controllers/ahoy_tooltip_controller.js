import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    label: String
  }

  track () {
    ahoy.track('tooltip clicked', { tooltip: this.labelValue }) // eslint-disable-line no-undef
  }
}
