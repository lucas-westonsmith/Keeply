import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Ensure flatpickr is globally available
    flatpickr(this.element, {
      dateFormat: "d-m-Y", // Customize the format here
    });
  }
}
