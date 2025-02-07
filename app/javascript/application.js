// app/javascript/application.js

import "@hotwired/turbo-rails";  // Turbo pour les transitions rapides sans rechargement
import "controllers";  // Stimulus controllers
import "@popperjs/core";  // Popper.js pour les dropdowns Bootstrap
import "bootstrap";  // Bootstrap JS

console.log("✅ Application JS chargé avec Bootstrap et Stimulus!");

// ✅ S'assurer que les scripts s'exécutent après navigation avec Turbo
document.addEventListener("turbo:load", () => {
  console.log("🔥 Turbo:load fired, réinitialisation des animations!");

  // ✅ Forcer le rechargement des animations GSAP après chaque navigation
  if (window.gsap && window.ScrollTrigger) {
    ScrollTrigger.refresh();
  }

  // ✅ Relancer les animations Stimulus si nécessaire
  if (window.Stimulus) {
    Stimulus.start();
  }
});

// ✅ Écoute les erreurs JS pour les repérer facilement en dev
window.onerror = function(message, source, lineno, colno, error) {
  console.error("💥 JavaScript Error:", message, "at", source, "line", lineno);
};
