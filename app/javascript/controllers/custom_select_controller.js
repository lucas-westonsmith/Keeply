import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initCustomSelects();
  }

  initCustomSelects() {
    const customSelects = this.element.querySelectorAll(".custom-select");

    customSelects.forEach((select) => {
      const trigger = select.querySelector(".custom-select-trigger");
      const options = select.querySelector(".custom-options");
      const hiddenInput = select.nextElementSibling;

      trigger.addEventListener("click", (event) => {
        event.stopPropagation();
        this.toggleDropdown(options);
      });

      options.querySelectorAll(".custom-option").forEach((option) => {
        option.addEventListener("click", () => {
          trigger.textContent = option.textContent;
          hiddenInput.value = option.dataset.value;
          options.style.display = "none";
        });
      });

      document.addEventListener("click", (event) => {
        if (!select.contains(event.target)) {
          options.style.display = "none";
        }
      });
    });
  }

  toggleDropdown(menu) {
    document.querySelectorAll(".custom-options").forEach((el) => {
      if (el !== menu) el.style.display = "none";
    });
    menu.style.display = menu.style.display === "block" ? "none" : "block";
  }
}
