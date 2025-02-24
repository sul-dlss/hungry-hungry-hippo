import { Controller } from "@hotwired/stimulus";

// Used to enable/disable a text area that is associated with a radio button,
// e.g. in a form where the user can select an option and then provide
// additional information in a text area. The text area is disabled by
// default, and is only enabled when the corresponding radio button is
// selected.
export default class extends Controller {
  // When any radio button is changed, evaluate state of text area for all of
  // them and enable/disable as appropriate. HTML radio buttons don't fire
  // an event on deselect, so we have to manually update the state of all
  // radio buttons in the group.
  toggleTextAreas(event) {
    this.element.querySelectorAll("input[type='radio']").forEach((radio) => {
      // Get the first text area that is grouped with this radio button inside
      // a bootstrap .form-check container; bail out if there is none
      const container = radio.closest(".form-check");
      if (!container) return;
      const textArea = container.querySelector("textarea");
      if (!textArea) return;

      // If this button was clicked, enable the text area and make it required
      // Otherwise, disable the text area and remove required
      if (radio == event.target) {
        textArea.removeAttribute("disabled");
        textArea.setAttribute("required", "true");
      } else {
        textArea.setAttribute("disabled", "true");
        textArea.removeAttribute("required");
      }
    });
  }
}
