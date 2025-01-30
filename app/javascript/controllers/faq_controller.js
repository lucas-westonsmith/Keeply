import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["answer", "icon"];

  connect() {
    this.openIndex = null; // Stocke l'index de la question actuellement ouverte
  }

  toggle(event) {
    const index = event.currentTarget.dataset.index;
    const answer = this.answerTargets[index];
    const icon = this.iconTargets[index];

    // Si une autre question était ouverte, la fermer
    if (this.openIndex !== null && this.openIndex !== index) {
      const previousAnswer = this.answerTargets[this.openIndex];
      const previousIcon = this.iconTargets[this.openIndex];
      previousAnswer.style.display = "none";
      previousIcon.classList.remove("fa-minus");
      previousIcon.classList.add("fa-plus");
    }

    // Toggle la question actuelle
    if (answer.style.display === "block") {
      answer.style.display = "none";
      icon.classList.remove("fa-minus");
      icon.classList.add("fa-plus");
      this.openIndex = null;
    } else {
      answer.style.display = "block";
      icon.classList.remove("fa-plus");
      icon.classList.add("fa-minus");
      this.openIndex = index;
    }
  }
}
