import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["popup"];

  connect() {
    console.log("🚀 sell_popup_controller.js is loaded and running!");

    // ✅ Ajoute un écouteur sur le bouton "Sell this item"
    const openButton = document.querySelector("[data-action='click->sell-popup#openPopup']");
    if (openButton) {
      openButton.addEventListener("click", (event) => this.openPopup(event));
      console.log("✅ Event listener ajouté sur le bouton Sell this item");
    } else {
      console.log("❌ Bouton Sell this item non trouvé");
    }

    // ✅ Ajoute un écouteur de clic pour fermer en dehors du pop-up
    document.addEventListener("click", (event) => this.clickOutsideToClose(event));
  }

  openPopup(event) {
    event.preventDefault();
    console.log("🟡 openPopup() is triggered!");

    if (this.hasPopupTarget) {
      this.popupTarget.classList.remove("hidden");
      console.log("✅ Popup ouvert !");

      // ✅ Désactive temporairement la détection du clic extérieur pendant 200ms
      this.preventOutsideClick = true;
      setTimeout(() => {
        this.preventOutsideClick = false;
      }, 200);
    } else {
      console.log("❌ popupTarget non trouvé !");
    }
  }

  closePopup(event) {
    event.preventDefault();
    console.log("🔴 Closing pop-up");

    if (this.hasPopupTarget) {
      this.popupTarget.classList.add("hidden");
      console.log("✅ Popup fermé !");
    } else {
      console.log("❌ popupTarget non trouvé !");
    }
  }

  clickOutsideToClose(event) {
    if (this.preventOutsideClick) {
      console.log("🟠 Fermeture désactivée temporairement pour éviter l'auto-fermeture.");
      return;
    }

    if (this.hasPopupTarget && !this.popupTarget.querySelector(".sell-popup-content").contains(event.target)) {
      console.log("🟠 Clic en dehors du pop-up détecté, fermeture !");
      this.popupTarget.classList.add("hidden");
    }
  }
}
