import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["listSelect", "categoriesContainer"];

  connect() {
    console.log("📡 Stimulus chargé, prêt à mettre à jour les catégories.");
    this.verifyTargets();
  }

  verifyTargets() {
    if (!this.hasListSelectTarget) {
      console.warn("⚠️ listSelect manquant, vérification annulée.");
      return;
    }

    if (!this.hasCategoriesContainerTarget) {
      console.warn("⚠️ categoriesContainer manquant, vérification annulée.");
      return;
    }

    console.log("✅ Les cibles sont bien détectées !");
  }

  updateCategories() {
    console.log("🖱️ Interaction utilisateur détectée");

    if (!this.hasListSelectTarget) {
      console.warn("🚨 listSelect introuvable, annulation.");
      return;
    }

    let selectedListIds = Array.from(this.listSelectTarget.querySelectorAll("input[type=checkbox]:checked"))
      .map(input => input.value) // ✅ Prend les IDs des listes
      .filter(id => id); // ✅ Évite les valeurs vides

    console.log("🔍 Listes sélectionnées (IDs) :", selectedListIds);

    if (selectedListIds.length === 0) {
      console.warn("⚠️ Aucune liste sélectionnée, suppression des catégories.");
      this.clearCategoryDropdown();
      return;
    }

    console.log("🚀 Envoi de la requête AJAX à `/items/update_categories?lists=`", selectedListIds.join(","));

    fetch(`/items/update_categories?lists=${encodeURIComponent(selectedListIds.join(","))}`)
      .then(response => {
        if (!response.ok) throw new Error(`Erreur AJAX: ${response.statusText}`);
        return response.text();
      })
      .then(html => {
        if (!this.hasCategoriesContainerTarget) {
          console.error("🚨 Élément `categoriesContainer` introuvable !");
          return;
        }

        if (this.categoriesContainerTarget.innerHTML !== html) {
          this.categoriesContainerTarget.innerHTML = html;
          console.log("✅ Catégories mises à jour !");
        } else {
          console.log("⏳ Aucune mise à jour nécessaire.");
        }
      })
      .catch(error => console.error("❌ Erreur AJAX :", error));
  }

  clearCategoryDropdown() {
    if (this.hasCategoriesContainerTarget) {
      this.categoriesContainerTarget.innerHTML = "<p class='form-note'>No categories available.</p>";
    }
  }
}
