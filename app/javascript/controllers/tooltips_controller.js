import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static targets = ['icon']

  iconTargetConnected (target) {
    const tooltip = new bootstrap.Tooltip(target)

    target.addEventListener('show.bs.tooltip', () => this.hideAllExcept(target))

    return tooltip
  }

  // Hide all tooltips (e.g., when switching tabs)
  hideAll (_event) {
    this.iconTargets.forEach(iconTarget => bootstrap.Tooltip.getInstance(iconTarget).hide())
  }

  // Display only one tooltip on the page at a time
  hideAllExcept (target) {
    this.iconTargets
      .filter(iconTarget => iconTarget !== target)
      .forEach(iconTarget => bootstrap.Tooltip.getInstance(iconTarget).hide())
  }
}
