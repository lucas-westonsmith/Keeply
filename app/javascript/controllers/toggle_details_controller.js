import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["details", "button"];

  connect() {
    this.expanded = false;
  }

  toggle() {
    this.expanded = !this.expanded;
    if (this.expanded) {
      this.detailsTarget.style.maxHeight = this.detailsTarget.scrollHeight + "px";
      this.buttonTarget.innerText = "Hide details";
    } else {
      this.detailsTarget.style.maxHeight = "0px";
      this.buttonTarget.innerText = "More details";
    }
  }
}
