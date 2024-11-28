import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["citation", "identifier", "useCitation"]
  static values = { citationContainerSelector: String }

  connect() {
    this.toggleCitation()
  }

  toggleCitation() {
    // If the `use_citation` box is checked, the user wants to use a citation
    // rather than an identifier as the value of the related work. When the box
    // is checked, we unhide the div that contains the citation field, enable
    // the citation field, and disable the identifier field. When the box is
    // unchecked, we disable the identifier field, enable the citation field,
    // and hide the div that contains the citation field.
    if (this.useCitationTarget.checked) {
      this.citationTarget.closest(this.citationContainerSelectorValue).hidden = false
      this.citationTarget.disabled = false
      this.identifierTarget.disabled = true
    } else {
      this.identifierTarget.disabled = false
      this.citationTarget.disabled = true
      this.citationTarget.closest(this.citationContainerSelectorValue).hidden = true
    }
  }
}
