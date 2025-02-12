// app/javascript/application.js

import "@hotwired/turbo-rails";  // Turbo pour les transitions rapides sans rechargement
import "controllers";  // Stimulus controllers
import "@popperjs/core";  // Popper.js pour les dropdowns Bootstrap
import "bootstrap";  // Bootstrap JS

console.log("✅ Application JS chargé avec Bootstrap et Stimulus!");

document.addEventListener("turbo:load", () => {
  console.log("🔥 Turbo:load fired, réinitialisation des animations!");

  // ✅ Gestion du back-button au scroll avec fade-out progressif
  const backButton = document.querySelector(".back-button");
  if (backButton) {
    let lastScrollY = window.scrollY;

    window.addEventListener("scroll", () => {
      if (window.scrollY > 50 && lastScrollY < window.scrollY) {
        backButton.classList.add("fading"); // Déclenche le fade-out
        setTimeout(() => backButton.classList.add("hidden"), 500); // Disparition après le fade
      } else {
        backButton.classList.remove("hidden");
        backButton.classList.remove("fading"); // Réaffichage avec fade-in
      }
      lastScrollY = window.scrollY;
    });
  }
});

// ✅ Écoute les erreurs JS pour les repérer facilement en dev
window.onerror = function(message, source, lineno, colno, error) {
  console.error("💥 JavaScript Error:", message, "at", source, "line", lineno);
};
