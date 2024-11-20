import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab", "pane" ]

  connect() {
    // For each tab / pane pair, check if the pane contains an invalid input.
    // If it does, add the is-invalid class to the tab.
    this.tabTargets.forEach((tabEl, index) => {
      const paneEl = this.paneTargets[index];
      if (paneEl.querySelector('.is-invalid')) {
        tabEl.classList.add('is-invalid');
      }
    })
    // Show the first tab that has an invalid input.
    const firstErrorTabEl = this.tabTargets.find(tabEl => tabEl.classList.contains('is-invalid'));
    if (firstErrorTabEl) {
      bootstrap.Tab.getOrCreateInstance(firstErrorTabEl).show();
    }
  }
}
